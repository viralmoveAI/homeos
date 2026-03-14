import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/emergency_contact.dart';
import '../../data/repositories/emergency_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return EmergencyRepository(uid);
});

final emergencyContactsProvider = StreamProvider<List<EmergencyContact>>((ref) {
  return ref.watch(emergencyRepositoryProvider).watchContacts();
});

class EmergencyNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addContact(EmergencyContact contact) async {
    await ref.read(emergencyRepositoryProvider).addContact(contact);
  }

  Future<void> updateContact(EmergencyContact contact) async {
    await ref.read(emergencyRepositoryProvider).updateContact(contact);
  }

  Future<void> deleteContact(String id) async {
    await ref.read(emergencyRepositoryProvider).deleteContact(id);
  }
}

final emergencyNotifierProvider = NotifierProvider<EmergencyNotifier, void>(() {
  return EmergencyNotifier();
});
