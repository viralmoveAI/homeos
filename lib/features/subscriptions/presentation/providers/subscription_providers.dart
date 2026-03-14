import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/subscription.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return SubscriptionRepository(uid);
});

final subscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscriptions();
});

class SubscriptionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addSubscription(Subscription subscription) async {
    await ref
        .read(subscriptionRepositoryProvider)
        .addSubscription(subscription);
  }

  Future<void> updateSubscription(Subscription subscription) async {
    await ref
        .read(subscriptionRepositoryProvider)
        .updateSubscription(subscription);
  }

  Future<void> deleteSubscription(String id) async {
    await ref.read(subscriptionRepositoryProvider).deleteSubscription(id);
  }
}

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, void>(() {
      return SubscriptionNotifier();
    });
