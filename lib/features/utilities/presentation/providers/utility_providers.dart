import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/utility.dart';
import '../../data/repositories/utility_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final utilityRepositoryProvider = Provider<UtilityRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return UtilityRepository(uid);
});

final utilitiesProvider = StreamProvider<List<Utility>>((ref) {
  return ref.watch(utilityRepositoryProvider).watchUtilities();
});

class UtilityNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addUtility(Utility utility) async {
    await ref.read(utilityRepositoryProvider).addUtility(utility);
  }

  Future<void> updateUtility(Utility utility) async {
    await ref.read(utilityRepositoryProvider).updateUtility(utility);
  }

  Future<void> deleteUtility(String id) async {
    await ref.read(utilityRepositoryProvider).deleteUtility(id);
  }
}

final utilityNotifierProvider = NotifierProvider<UtilityNotifier, void>(() {
  return UtilityNotifier();
});
