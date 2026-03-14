import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FamilyHubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String
  _targetUid; // The UID of the family (either current user or their admin)
  final String _currentUid; // The UID of the person performing the action

  FamilyHubService({required String targetUid, required String currentUid})
    : _targetUid = targetUid,
      _currentUid = currentUid;

  // Shorthand: users/{targetUid}
  DocumentReference get _familyDoc => _db.collection('users').doc(_targetUid);

  // ─── Posts ───────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> postsStream() {
    return _familyDoc
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> uploadImage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final taskSnapshot = await ref.putFile(file);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> createPost({required String content, String? imageUrl}) async {
    final userData = await _db.collection('users').doc(_currentUid).get();
    final name = userData.data()?['firstName'] ?? 'User';

    await _familyDoc.collection('posts').add({
      'authorId': _currentUid,
      'authorName': name,
      'content': content,
      'imageUrl': imageUrl,
      'reactions': {'❤️': [], '👍': [], '😂': [], '😮': [], '😢': []},
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editPost(
    String postId,
    String newContent,
    String? newImageUrl,
  ) async {
    final updateData = <String, dynamic>{
      'content': newContent,
      if (newImageUrl != null) 'imageUrl': newImageUrl,
    };
    await _familyDoc.collection('posts').doc(postId).update(updateData);
  }

  Future<void> deletePost(String postId) async {
    await _familyDoc.collection('posts').doc(postId).delete();
  }

  Future<void> toggleReaction({
    required String postId,
    required String emoji,
  }) async {
    final postRef = _familyDoc.collection('posts').doc(postId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(postRef);
      if (!snap.exists) return;
      final reactions = Map<String, dynamic>.from(
        snap.data()?['reactions'] ?? {},
      );

      final keys = reactions.keys.toSet()..add(emoji);
      for (final key in keys) {
        final list = List<String>.from(reactions[key] as List? ?? []);
        if (key == emoji) {
          if (list.contains(_currentUid)) {
            list.remove(_currentUid);
          } else {
            list.add(_currentUid);
          }
        } else {
          list.remove(_currentUid);
        }
        reactions[key] = list;
      }

      tx.update(postRef, {'reactions': reactions});
    });
  }

  // ─── Comments ─────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> commentsStream(String postId) {
    return _familyDoc
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final userData = await _db.collection('users').doc(_currentUid).get();
    final name = userData.data()?['firstName'] ?? 'User';

    final batch = _db.batch();
    final commentRef = _familyDoc
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();
    final postRef = _familyDoc.collection('posts').doc(postId);

    batch.set(commentRef, {
      'authorId': _currentUid,
      'authorName': name,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(postRef, {'commentCount': FieldValue.increment(1)});

    await batch.commit();
  }

  // ─── Chat Groups ──────────────────────────────────────────────────────────

  Stream<QuerySnapshot> chatGroupsStream() {
    return _familyDoc
        .collection('chatGroups')
        .where('members', arrayContains: _currentUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  Future<String> createChatGroup({
    required String name,
    required String emoji,
    required List<String> members,
  }) async {
    // Make sure current user is in members list
    final List<String> finalMembers = List.from(members);
    if (!finalMembers.contains(_currentUid)) {
      finalMembers.add(_currentUid);
    }

    final ref = await _familyDoc.collection('chatGroups').add({
      'name': name,
      'emoji': emoji,
      'members': finalMembers,
      'lastMessage': 'Group created',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdBy': _currentUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> deleteChatGroup(String groupId) async {
    await _familyDoc.collection('chatGroups').doc(groupId).delete();
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> messagesStream(String groupId) {
    return _familyDoc
        .collection('chatGroups')
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
    String? imageUrl,
  }) async {
    final userData = await _db.collection('users').doc(_currentUid).get();
    final name = userData.data()?['firstName'] ?? 'User';

    final batch = _db.batch();
    final msgRef = _familyDoc
        .collection('chatGroups')
        .doc(groupId)
        .collection('messages')
        .doc();
    final groupRef = _familyDoc.collection('chatGroups').doc(groupId);

    batch.set(msgRef, {
      'senderId': _currentUid,
      'senderName': name,
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(groupRef, {
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> editMessage(
    String groupId,
    String messageId,
    String newText,
  ) async {
    await _familyDoc
        .collection('chatGroups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({'text': newText});
  }

  Future<void> deleteMessage(String groupId, String messageId) async {
    await _familyDoc
        .collection('chatGroups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
