import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/emergency_contact.dart';

class EmergencyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid;

  EmergencyRepository(this._uid);

  CollectionReference get _collection =>
      _firestore.collection('users').doc(_uid).collection('emergency_contacts');

  Stream<List<EmergencyContact>> watchContacts() {
    return _collection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmergencyContact.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Future<void> addContact(EmergencyContact contact) async {
    await _collection.add(contact.toJson());
  }

  Future<void> updateContact(EmergencyContact contact) async {
    await _collection.doc(contact.id).update(contact.toJson());
  }

  Future<void> deleteContact(String id) async {
    await _collection.doc(id).delete();
  }
}
