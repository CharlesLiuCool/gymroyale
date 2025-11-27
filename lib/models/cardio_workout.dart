// lib/models/cardio_workout.dart

import 'package:gymroyale/models/workout_activity.dart';

class CardioWorkout extends WorkoutActivity {
  final Duration duration;

  CardioWorkout({
    required super.id,
    required super.title,
    required super.startedAt,
    required this.duration,
  }) : super(
         activityType: ActivityType.cardio,
       );

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'activityType': activityType.name,
    'startedAt': startedAt.toIso8601String(),
    'durationMinutes': duration.inMinutes,
  };

  static CardioWorkout fromMap(Map<String, dynamic> map) => CardioWorkout(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    startedAt: parseStartedAt(map['startedAt']),
    duration: Duration(minutes: (map['durationMinutes'] as int?) ?? 0),
  );

  @override
  Map<String, dynamic> toJson() => toMap();

  static CardioWorkout fromJson(Map<String, dynamic> json) => fromMap(json);
}
