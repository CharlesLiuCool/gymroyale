import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users'; // store users in Firestore

  /// Real-time stream of top users
  Stream<List<User>> topUsers({int limit = 10}) {
    return _firestore
        .collection(_collection)
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

  /// Increment user's points (e.g., on gym check-in)
  Future<void> addPoints(String userId, int pointsToAdd) async {
    final docRef = _firestore.collection(_collection).doc(userId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        // Create user if doesn't exist
        transaction.set(docRef, {'name': 'User', 'points': pointsToAdd});
      } else {
        final currentPoints = snapshot.get('points') ?? 0;
        transaction.update(docRef, {'points': currentPoints + pointsToAdd});
      }
    });
  }
}
