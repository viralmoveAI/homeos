import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/vehicle.dart';

class VehicleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid;

  VehicleRepository(this._uid);

  CollectionReference get _collection =>
      _firestore.collection('users').doc(_uid).collection('vehicles');

  Stream<List<Vehicle>> watchVehicles() {
    return _collection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _collection.add(vehicle.toJson());
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _collection.doc(vehicle.id).update(vehicle.toJson());
  }

  Future<void> deleteVehicle(String id) async {
    await _collection.doc(id).delete();
  }
}
