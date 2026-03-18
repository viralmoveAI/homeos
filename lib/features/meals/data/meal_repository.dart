import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/meal_poll.dart';

class MealRepository {
  final String uid;

  MealRepository({required this.uid});

  CollectionReference get _pollsCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('meal_polls');

  Stream<List<MealPoll>> watchPolls() {
    return _pollsCollection.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MealPoll.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addPoll(MealPoll poll) async {
    await _pollsCollection.add(poll.toMap());
  }

  Future<void> updatePoll(MealPoll poll) async {
    await _pollsCollection.doc(poll.id).update(poll.toMap());
  }

  Future<void> deletePoll(String pollId) async {
    await _pollsCollection.doc(pollId).delete();
  }

  Future<void> vote(String pollId, String optionId, String voterUid) async {
    final pollDoc = await _pollsCollection.doc(pollId).get();
    if (!pollDoc.exists) return;

    final data = pollDoc.data() as Map<String, dynamic>;
    final poll = MealPoll.fromMap({...data, 'id': pollDoc.id});

    final updatedOptions = poll.options.map((option) {
      // Remove vote from all options first (one vote per poll)
      final newVotes = List<String>.from(option.votes)..remove(voterUid);

      // If this is the selected option, add the vote
      if (option.id == optionId) {
        newVotes.add(voterUid);
      }

      return option.copyWith(votes: newVotes);
    }).toList();

    await _pollsCollection.doc(pollId).update({
      'options': updatedOptions.map((e) => e.toMap()).toList(),
    });
  }
}
