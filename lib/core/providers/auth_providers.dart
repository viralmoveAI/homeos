import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
});

final effectiveUidProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  final profile = ref.watch(userProfileProvider).value;
  // While profile is loading or if it's not found yet, use the current user's UID
  // This avoids a complete block while the first profile fetch happens
  final familyAdminUid = profile?['familyAdminUid'] as String?;
  return familyAdminUid ?? user.uid;
});
