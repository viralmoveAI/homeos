import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/appliance.dart';

class ApplianceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid;

  ApplianceRepository(this._uid);

  CollectionReference get _collection =>
      _firestore.collection('users').doc(_uid).collection('appliances');

  Stream<List<Appliance>> watchAppliances() {
    return _collection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appliance.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addAppliance(Appliance appliance) async {
    await _collection.add(appliance.toJson());
  }

  Future<void> updateAppliance(Appliance appliance) async {
    await _collection.doc(appliance.id).update(appliance.toJson());
  }

  Future<void> deleteAppliance(String id) async {
    await _collection.doc(id).delete();
  }
}
