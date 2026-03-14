import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/maintenance_task.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return MaintenanceRepository(uid: uid);
});

final maintenanceTasksProvider = StreamProvider<List<MaintenanceTask>>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.watchTasks();
});

class MaintenanceNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addTask(MaintenanceTask task) async {
    await ref.read(maintenanceRepositoryProvider).addTask(task);
  }

  Future<void> updateTask(MaintenanceTask task) async {
    await ref.read(maintenanceRepositoryProvider).updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await ref.read(maintenanceRepositoryProvider).deleteTask(taskId);
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await ref
        .read(maintenanceRepositoryProvider)
        .toggleTaskCompletion(taskId, isCompleted);
  }
}

final maintenanceNotifierProvider = NotifierProvider<MaintenanceNotifier, void>(
  () {
    return MaintenanceNotifier();
  },
);
