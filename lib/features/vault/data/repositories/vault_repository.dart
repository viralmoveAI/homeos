import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/vault_document.dart';

class VaultRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  VaultRepository({required String uid, FirebaseFirestore? firestore})
    : _uid = uid,
      _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vaultCollection =>
      _firestore.collection('users').doc(_uid).collection('vault_documents');

  Stream<List<VaultDocument>> watchDocuments() {
    return _vaultCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VaultDocument.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addDocument(VaultDocument document) async {
    await _vaultCollection.add(document.toJson());
  }

  Future<void> updateDocument(VaultDocument document) async {
    await _vaultCollection.doc(document.id).update(document.toJson());
  }

  Future<void> deleteDocument(String documentId) async {
    await _vaultCollection.doc(documentId).delete();
  }
}
