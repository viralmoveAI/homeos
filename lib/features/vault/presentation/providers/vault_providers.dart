import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vault_document.dart';
import '../../data/repositories/vault_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return VaultRepository(uid: uid);
});

final vaultDocumentsProvider = StreamProvider<List<VaultDocument>>((ref) {
  final repository = ref.watch(vaultRepositoryProvider);
  return repository.watchDocuments();
});

class VaultNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addDocument(VaultDocument document) async {
    await ref.read(vaultRepositoryProvider).addDocument(document);
  }

  Future<void> updateDocument(VaultDocument document) async {
    await ref.read(vaultRepositoryProvider).updateDocument(document);
  }

  Future<void> deleteDocument(String documentId) async {
    await ref.read(vaultRepositoryProvider).deleteDocument(documentId);
  }
}

final vaultNotifierProvider = NotifierProvider<VaultNotifier, void>(() {
  return VaultNotifier();
});
