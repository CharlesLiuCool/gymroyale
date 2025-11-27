// lib/models/lift_workout.dart

import 'package:gymroyale/models/workout_activity.dart';

class LiftWorkout extends WorkoutActivity {
  final double weight;
  final int sets;
  final int reps;

  LiftWorkout({
    required super.id,
    required super.title,
    required super.startedAt,
    required this.weight,
    required this.sets,
    required this.reps,
  }) : super(
         activityType: ActivityType.lift,
       );

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'activityType': activityType.name,
    'startedAt': startedAt.toIso8601String(),
    'weight': weight,
    'sets': sets,
    'reps': reps,
  };

  static LiftWorkout fromMap(Map<String, dynamic> map) => LiftWorkout(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    startedAt: parseStartedAt(map['startedAt']),
    weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
    sets: (map['sets'] as int?) ?? 0,
    reps: (map['reps'] as int?) ?? 0,
  );

  @override
  Map<String, dynamic> toJson() => toMap();

  static LiftWorkout fromJson(Map<String, dynamic> json) => fromMap(json);
}
