import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal_poll.dart';
import '../../data/meal_repository.dart';
import '../../../../core/providers/auth_providers.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final uid = ref.watch(effectiveUidProvider);
  if (uid == null) throw Exception('User not authenticated');
  return MealRepository(uid: uid);
});

final mealPollsProvider = StreamProvider<List<MealPoll>>((ref) {
  final repository = ref.watch(mealRepositoryProvider);
  return repository.watchPolls();
});

class MealNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addPoll(MealPoll poll) async {
    await ref.read(mealRepositoryProvider).addPoll(poll);
  }

  Future<void> updatePoll(MealPoll poll) async {
    await ref.read(mealRepositoryProvider).updatePoll(poll);
  }

  Future<void> deletePoll(String pollId) async {
    await ref.read(mealRepositoryProvider).deletePoll(pollId);
  }

  Future<void> vote(String pollId, String optionId) async {
    final authUser = ref.read(authStateProvider).value;
    if (authUser == null) return;
    await ref.read(mealRepositoryProvider).vote(pollId, optionId, authUser.uid);
  }
}

final mealNotifierProvider = NotifierProvider<MealNotifier, void>(() {
  return MealNotifier();
});
