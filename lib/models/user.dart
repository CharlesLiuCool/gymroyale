import 'workout_activity.dart';

class User {
  final String id;
  final String name;
  final int points;
  final int? rank;
  final List<WorkoutActivity>? workouts;
  final int? streakCount;

  User({
    required this.id,
    required this.name,
    required this.points,
    this.rank,
    this.workouts,
    this.streakCount,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] as String? ?? 'User',
      points:
          map['points'] is int
              ? map['points'] as int
              : int.tryParse(map['points'].toString()) ?? 0,
      workouts:
          map['workouts'] != null
              ? (map['workouts'] as List)
                  .map((w) => parseWorkout(Map<String, dynamic>.from(w)))
                  .toList()
              : null,
      streakCount: map['streakCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'points': points,
      'streakCount': streakCount,
      if (workouts != null)
        'workouts': workouts!.map((w) => w.toMap()).toList(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    int? points,
    int? rank,
    List<WorkoutActivity>? workouts,
    int? streakCount,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      workouts: workouts ?? this.workouts,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
      workouts:
          json['workouts'] != null
              ? (json['workouts'] as List)
                  .map((w) => parseWorkout(Map<String, dynamic>.from(w)))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points': points,
    'streakCount': streakCount,
    if (workouts != null) 'workouts': workouts!.map((w) => w.toJson()).toList(),
  };
}
