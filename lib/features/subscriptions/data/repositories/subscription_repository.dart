import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/subscription.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid;

  SubscriptionRepository(this._uid);

  CollectionReference get _collection =>
      _firestore.collection('users').doc(_uid).collection('subscriptions');

  Stream<List<Subscription>> watchSubscriptions() {
    return _collection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subscription.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Future<void> addSubscription(Subscription subscription) async {
    await _collection.add(subscription.toJson());
  }

  Future<void> updateSubscription(Subscription subscription) async {
    await _collection.doc(subscription.id).update(subscription.toJson());
  }

  Future<void> deleteSubscription(String id) async {
    await _collection.doc(id).delete();
  }
}
