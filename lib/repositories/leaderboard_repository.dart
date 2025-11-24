import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/user_history.dart';
import '../models/user_point_entry.dart';
import 'package:rxdart/rxdart.dart';

class LeaderboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Stream of top users ordered by points
  Stream<List<User>> topUsers({int limit = 20}) {
    return _users
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => User.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<bool> userExists(String userId) async {
    final doc = await _users.doc(userId).get();
    return doc.exists;
  }

  Future<void> addUser(String userId, String name, int points) async {
    await _users.doc(userId).set({
      'name': name,
      'points': points,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Also add history entry
    await _users.doc(userId).collection('history').add({
      'timestamp': FieldValue.serverTimestamp(),
      'points': points,
    });
  }

  /// Add or increment points for a user, AND log history
  Future<void> addPoints(String userId, int delta) async {
    final ref = _users.doc(userId);
    final doc = await ref.get();

    int newPoints = delta;

    if (!doc.exists) {
      // Create missing user doc
      await ref.set({
        'points': delta,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      final currentPoints = doc['points'] ?? 0;
      newPoints = currentPoints + delta;

      await ref.update({'points': FieldValue.increment(delta)});
    }

    // Write history entry
    await ref.collection('history').add({
      'timestamp': FieldValue.serverTimestamp(),
      'points': newPoints,
    });
  }

  Future<User?> getUser(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateUsername(String userId, String newName) async {
    await _users.doc(userId).update({'name': newName});
  }

  Stream<List<UserHistory>> watchTopUserHistory(List<User> users) {
    final streams =
        users.map((user) {
          return _users
              .doc(user.id)
              .collection('history')
              .orderBy('timestamp')
              .snapshots()
              .map((snapshot) {
                final entries =
                    snapshot.docs
                        .where((d) => d['timestamp'] != null)
                        .map((d) => UserPointEntry.fromMap(d.data()))
                        .toList();

                return UserHistory(
                  userId: user.id,
                  name: user.name,
                  history: entries,
                );
              });
        }).toList();

    return Rx.combineLatestList<UserHistory>(
      streams.map(
        (stream) =>
            stream.startWith(UserHistory(userId: "", name: "", history: [])),
      ),
    );
  }
}
