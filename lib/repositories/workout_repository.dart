import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_activity.dart';

class WorkoutRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<WorkoutActivity>> fetchUserWorkouts(String userId) async {
    final snapshot =
        await _db
            .collection('users')
            .doc(userId)
            .collection('workouts')
            .orderBy('startedAt', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return WorkoutActivity(
        id: doc.id,
        title: data['title'] ?? '',
        activityType: ActivityType.values.firstWhere(
          (e) => e.name == data['activityType'],
          orElse: () => ActivityType.lift,
        ),
        startedAt: (data['startedAt'] as Timestamp).toDate(),
        movingTime: Duration(seconds: data['movingTime'] ?? 0),
        likeCount: data['likeCount'] ?? 0,
        commentsCount: data['commentsCount'] ?? 0,
      );
    }).toList();
  }
}
