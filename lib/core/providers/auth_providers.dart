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

  final profileAsync = ref.watch(userProfileProvider);

  // Wait for the profile to load to ensure we have the correct familyAdminUid if it exists.
  // This prevents creating data in the user's own collection before we know they belong to a family.
  return profileAsync.maybeWhen(
    data: (profile) {
      final familyAdminUid = profile?['familyAdminUid'] as String?;
      return familyAdminUid ?? user.uid;
    },
    // While loading or in error, we return null to suspend dependent services
    // until we are sure about the target UID.
    orElse: () => null,
  );
});
