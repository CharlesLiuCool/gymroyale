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
      data['id'] = doc.id;
      return parseWorkout(data);
    }).toList();
  }

  Future<void> addWorkout(String userId, WorkoutActivity workout) async {
    final ref = _db.collection('users').doc(userId).collection('workouts');
    await ref.add(workout.toMap());
  }

  Future<void> deleteWorkout(String userId, String workoutId) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId);

    await ref.delete();
  }

  Future<void> updateWorkout(String userId, WorkoutActivity workout) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workout.id);

    await ref.update(workout.toMap());
  }

  Stream<List<WorkoutActivity>> watchUserWorkouts(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return parseWorkout(data);
          }).toList();
        });
  }
}
