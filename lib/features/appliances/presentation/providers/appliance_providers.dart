import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/appliance.dart';
import '../../data/repositories/appliance_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final applianceRepositoryProvider = Provider<ApplianceRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return ApplianceRepository(uid);
});

final appliancesProvider = StreamProvider<List<Appliance>>((ref) {
  return ref.watch(applianceRepositoryProvider).watchAppliances();
});

class ApplianceNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addAppliance(Appliance appliance) async {
    await ref.read(applianceRepositoryProvider).addAppliance(appliance);
  }

  Future<void> updateAppliance(Appliance appliance) async {
    await ref.read(applianceRepositoryProvider).updateAppliance(appliance);
  }

  Future<void> deleteAppliance(String id) async {
    await ref.read(applianceRepositoryProvider).deleteAppliance(id);
  }
}

final applianceNotifierProvider = NotifierProvider<ApplianceNotifier, void>(() {
  return ApplianceNotifier();
});
