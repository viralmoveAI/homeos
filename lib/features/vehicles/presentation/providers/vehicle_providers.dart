import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return VehicleRepository(uid);
});

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(vehicleRepositoryProvider).watchVehicles();
});

class VehicleNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addVehicle(Vehicle vehicle) async {
    await ref.read(vehicleRepositoryProvider).addVehicle(vehicle);
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await ref.read(vehicleRepositoryProvider).updateVehicle(vehicle);
  }

  Future<void> deleteVehicle(String id) async {
    await ref.read(vehicleRepositoryProvider).deleteVehicle(id);
  }
}

final vehicleNotifierProvider = NotifierProvider<VehicleNotifier, void>(() {
  return VehicleNotifier();
});
