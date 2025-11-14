import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class LeaderboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Stream of top users ordered by points (for leaderboard)
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

  /// Check if a user document already exists
  Future<bool> userExists(String userId) async {
    final doc = await _users.doc(userId).get();
    return doc.exists;
  }

  /// Add a new user to Firestore leaderboard
  Future<void> addUser(String userId, String name, int points) async {
    await _users.doc(userId).set({
      'name': name,
      'points': points,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Add or increment points for a user
  Future<void> addPoints(String userId, int delta) async {
    final ref = _users.doc(userId);
    final doc = await ref.get();

    if (!doc.exists) {
      // Create a new doc if somehow missing
      await ref.set({
        'points': delta,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await ref.update({'points': FieldValue.increment(delta)});
    }
  }

  /// Get a user once (non-stream)
  Future<User?> getUser(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data()!, doc.id);
  }

  /// Update username field in Firestore
  Future<void> updateUsername(String userId, String newName) async {
    await _users.doc(userId).update({'name': newName});
  }
}
