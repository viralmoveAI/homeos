import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/maintenance_task.dart';

class MaintenanceRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  MaintenanceRepository({required String uid, FirebaseFirestore? firestore})
    : _uid = uid,
      _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('users').doc(_uid).collection('maintenance_tasks');

  Stream<List<MaintenanceTask>> watchTasks() {
    return _tasksCollection
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MaintenanceTask.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addTask(MaintenanceTask task) async {
    await _tasksCollection.add(task.toJson());
  }

  Future<void> updateTask(MaintenanceTask task) async {
    await _tasksCollection.doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': isCompleted});
  }
}
