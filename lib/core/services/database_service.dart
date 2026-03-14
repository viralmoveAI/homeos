import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get current user and throw if null
  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated for database operations.');
    }
    return user;
  }

  // Get current user's document reference
  DocumentReference get _userDoc =>
      _db.collection('users').doc(_currentUser.uid);

  // ─── User Profile (Root Document) ──────────────────────────────────────────

  /// Creates or updates the user profile document at the root users collection.
  /// Uses SetOptions(merge: true) to avoid overwriting existing data.
  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    final uid = _currentUser.uid;

    final profileData = {
      ...userData,
      'uid': uid,
      'createdAt': userData['createdAt'] ?? FieldValue.serverTimestamp(),
    };

    await _db
        .collection('users')
        .doc(uid)
        .set(profileData, SetOptions(merge: true));
  }

  // ─── Generic Sub-collection Helpers ────────────────────────────────────────

  /// Adds a document to a specific sub-collection under the current user.
  Future<DocumentReference> _addToUserSubCollection(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    return await _userDoc.collection(collectionName).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns a stream of snapshots for a specific sub-collection under the current user.
  Stream<QuerySnapshot> _getUserSubCollectionStream(
    String collectionName, {
    String orderBy = 'createdAt',
    bool descending = true,
  }) {
    return _userDoc
        .collection(collectionName)
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  // ─── Posts ───────────────────────────────────────────────────────────────

  /// Adds a post strictly to users/{uid}/posts.
  Future<void> addPost(Map<String, dynamic> postData) async {
    await _addToUserSubCollection('posts', postData);
  }

  /// Fetches posts strictly from users/{uid}/posts, ordered by timestamp descending.
  Stream<QuerySnapshot> getUserPosts() {
    return _getUserSubCollectionStream('posts');
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  /// Adds a utility strictly to users/{uid}/utilities.
  Future<void> addUtility(Map<String, dynamic> utilityData) async {
    await _addToUserSubCollection('utilities', utilityData);
  }

  /// Fetches utilities strictly from users/{uid}/utilities, ordered by timestamp descending.
  Stream<QuerySnapshot> getUserUtilities() {
    return _getUserSubCollectionStream('utilities');
  }

  // ─── Appliances ───────────────────────────────────────────────────────────

  /// Adds an appliance strictly to users/{uid}/appliances.
  Future<void> addAppliance(Map<String, dynamic> applianceData) async {
    await _addToUserSubCollection('appliances', applianceData);
  }

  /// Fetches appliances strictly from users/{uid}/appliances, ordered by timestamp descending.
  Stream<QuerySnapshot> getUserAppliances() {
    return _getUserSubCollectionStream('appliances');
  }

  // ─── Family Management ────────────────────────────────────────────────────

  /// Fetches family members added by the current admin.
  Stream<QuerySnapshot> getFamilyMembers() {
    return _userDoc
        .collection('family_members')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  /// Removes a family member from the admin's list and updates their profile.
  Future<void> removeFamilyMember(String memberUid) async {
    final batch = _db.batch();

    // 1. Remove from admin's sub-collection
    final memberInAdminCol = _userDoc
        .collection('family_members')
        .doc(memberUid);
    batch.delete(memberInAdminCol);

    // 2. Remove familyAdminUid from the member's profile
    final memberProfile = _db.collection('users').doc(memberUid);
    batch.update(memberProfile, {
      'familyAdminUid': FieldValue.delete(),
      'role': 'User', // Revert to standard user
    });

    await batch.commit();
  }
}
