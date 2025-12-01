import 'workout_activity.dart';

class User {
  final String id;
  final String name;
  final int points;
  final List<WorkoutActivity>? workouts;
  final int? streakCount;
  final List<String> friends;

  User({
    required this.id,
    required this.name,
    required this.points,
    this.workouts,
    this.streakCount,
    this.friends = const [],
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] as String? ?? 'User',
      points:
          map['points'] is int
              ? map['points']
              : int.tryParse(map['points'].toString()) ?? 0,
      workouts:
          map['workouts'] != null
              ? (map['workouts'] as List)
                  .map((w) => parseWorkout(Map<String, dynamic>.from(w)))
                  .toList()
              : null,
      streakCount: map['streakCount'] as int?,
      friends: map['friends'] != null ? List<String>.from(map['friends']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'points': points,
      'streakCount': streakCount,
      if (workouts != null)
        'workouts': workouts!.map((w) => w.toMap()).toList(),
      'friends': friends,
    };
  }

  User copyWith({
    String? id,
    String? name,
    int? points,
    List<WorkoutActivity>? workouts,
    int? streakCount,
    List<String>? friends,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      workouts: workouts ?? this.workouts,
      streakCount: streakCount ?? this.streakCount,
      friends: friends ?? this.friends,
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
      streakCount: json['streakCount'] as int?,
      friends:
          json['friends'] != null ? List<String>.from(json['friends']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points': points,
    'streakCount': streakCount,
    if (workouts != null) 'workouts': workouts!.map((w) => w.toJson()).toList(),
    'friends': friends,
  };
}
