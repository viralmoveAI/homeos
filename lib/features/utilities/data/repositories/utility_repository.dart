import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/utility.dart';

class UtilityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid;

  UtilityRepository(this._uid);

  CollectionReference get _collection =>
      _firestore.collection('users').doc(_uid).collection('utilities');

  Stream<List<Utility>> watchUtilities() {
    return _collection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Utility.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addUtility(Utility utility) async {
    await _collection.add(utility.toJson());
  }

  Future<void> updateUtility(Utility utility) async {
    await _collection.doc(utility.id).update(utility.toJson());
  }

  Future<void> deleteUtility(String id) async {
    await _collection.doc(id).delete();
  }
}
