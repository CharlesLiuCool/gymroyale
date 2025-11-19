import 'package:cloud_firestore/cloud_firestore.dart';

import 'cardio_workout.dart';
import 'lift_workout.dart';

enum ActivityType { cardio, lift }

abstract class WorkoutActivity {
  final String id;
  final String title;
  final ActivityType activityType;
  final DateTime startedAt;

  WorkoutActivity({
    required this.id,
    required this.title,
    required this.activityType,
    required this.startedAt,
  });

  Map<String, dynamic> toMap();
  Map<String, dynamic> toJson();
}

DateTime parseStartedAt(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  throw ArgumentError('Invalid startedAt format: $value');
}

/// Factory function to parse a workout from Firestore or JSON
WorkoutActivity parseWorkout(Map<String, dynamic> map) {
  final type = ActivityType.values.firstWhere(
    (e) => e.name == map['activityType'],
    orElse: () => ActivityType.cardio,
  );

  switch (type) {
    case ActivityType.cardio:
      return CardioWorkout.fromMap(map);
    case ActivityType.lift:
      return LiftWorkout.fromMap(map);
  }
}
