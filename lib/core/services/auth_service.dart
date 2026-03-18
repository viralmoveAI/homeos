import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:emailjs/emailjs.dart' as emailjs;
import '../../firebase_options.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String familyName,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'familyName': familyName,
          'email': email,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'setupComplete': false,
        });
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google (v7.2.0 Compatible + Web Fix)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web optimized flow
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // 1. Trigger the authenticate flow (replaces signIn in v7)
        final GoogleSignInAccount googleUser = await _googleSignIn
            .authenticate();

        // 2. Obtain auth details (idToken)
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // 3. Obtain access token via authorizationClient
        final clientAuth = await googleUser.authorizationClient.authorizeScopes(
          ['email', 'profile', 'openid'],
        );

        // 4. Create Firebase credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: clientAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 5. Sign in to Firebase
        userCredential = await _auth.signInWithCredential(credential);
      }

      // 6. Save user metadata for new Google users
      if (userCredential.user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        final user = userCredential.user!;
        final displayName = user.displayName ?? '';

        await _firestore.collection('users').doc(user.uid).set({
          'firstName': displayName.split(' ').first,
          'familyName': displayName.split(' ').length > 1
              ? displayName.split(' ').last
              : '',
          'email': user.email ?? '',
          'phoneNumber': '',
          'createdAt': FieldValue.serverTimestamp(),
          'setupComplete': false,
          'photoUrl': user.photoURL,
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print('Error in Google Sign In: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw Exception('No user signed in');
    }
  }

  // ─── Family Invitations ──────────────────────────────────────────────────

  /// Invites a family member by creating a Firebase Auth account for them.
  /// Uses a secondary Firebase App to avoid signing out the current admin user.
  Future<User?> inviteFamilyMember({
    required String name,
    required String email,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      final adminUser = _auth.currentUser;
      if (adminUser == null) throw Exception('Admin not logged in');

      // 1. Generate a random password
      final password = _generateRandomPassword();
      print('DEBUG: Generated password for $email: $password');

      // 2. Initialize secondary app to create user
      secondaryApp = await Firebase.initializeApp(
        name: 'InviteMemberApp-${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // 3. Create the account
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = userCredential.user;
      if (newUser != null) {
        // 4. Update the member's profile
        await _firestore.collection('users').doc(newUser.uid).set({
          'firstName': name,
          'familyName': '', // Optional
          'email': email,
          'phoneNumber': '',
          'createdAt': FieldValue.serverTimestamp(),
          'setupComplete': false,
          'familyAdminUid': adminUser.uid,
          'role': 'Member',
        });

        // 5. Add to admin's family_members sub-collection
        await _firestore
            .collection('users')
            .doc(adminUser.uid)
            .collection('family_members')
            .doc(newUser.uid)
            .set({
              'uid': newUser.uid,
              'name': name,
              'email': email,
              'role': 'Member',
              'addedAt': FieldValue.serverTimestamp(),
            });

        // 6. Send Invitation Email via EmailJS
        await _sendInviteEmail(name: name, email: email, password: password);
      }

      return newUser;
    } catch (e) {
      print('Error inviting family member: $e');
      rethrow;
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  String _generateRandomPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> _sendInviteEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // NOTE: User needs to configure these values in their EmailJS dashboard
      // These are placeholders for the demonstration
      const serviceId = 'service_homeos';
      const templateId = 'template_invite';
      const publicKey = 'YOUR_EMAILJS_PUBLIC_KEY';

      await emailjs.send(serviceId, templateId, {
        'to_name': name,
        'to_email': email,
        'password': password,
        'login_url':
            'https://homeos-app.web.app/login', // Replace with actual URL
      }, const emailjs.Options(publicKey: publicKey));
      print('Invitation email sent to $email');
    } catch (e) {
      print('Failed to send email via EmailJS (check keys): $e');
      // We don't throw here to avoid failing the whole invite process
      // since the account IS created and logged in the console.
    }
  }
}
