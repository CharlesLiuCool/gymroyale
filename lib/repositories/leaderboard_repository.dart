import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class LeaderboardRepository {
  final FirebaseFirestore firestore;

  LeaderboardRepository({FirebaseFirestore? firestoreInstance})
    : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  /// Returns a Stream of List<User>
  Stream<List<User>> topUsers() {
    return firestore
        .collection('users')
        .orderBy('points', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => User.fromJson(doc.data())).toList(),
        );
  }
}
