import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../data/family_hub_service.dart';

final familyHubServiceProvider = Provider<FamilyHubService>((ref) {
  final targetUid = ref.watch(effectiveUidProvider);
  final authUser = ref.watch(authStateProvider).value;

  if (targetUid == null || authUser == null) {
    throw Exception('Not authenticated');
  }

  return FamilyHubService(targetUid: targetUid, currentUid: authUser.uid);
});

final familyPostsProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(familyHubServiceProvider).postsStream();
});

final familyChatGroupsProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(familyHubServiceProvider).chatGroupsStream();
});

final familyMembersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final targetUid = ref.watch(effectiveUidProvider);
  if (targetUid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(targetUid)
      .collection('family_members')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => {'uid': doc.id, ...doc.data()})
            .toList();
      });
});
