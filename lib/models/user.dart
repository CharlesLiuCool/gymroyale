import 'workout_activity.dart';

class User {
  final String id;
  final String name;
  final int points;
  final int? rank;
  final List<WorkoutActivity>? workouts;

  User({
    required this.id,
    required this.name,
    required this.points,
    this.rank,
    this.workouts,
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
                  .map((w) => WorkoutActivity.fromMap(w))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'points': points,
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
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      workouts: workouts ?? this.workouts,
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
                  .map((w) => WorkoutActivity.fromJson(w))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points': points,
    if (workouts != null) 'workouts': workouts!.map((w) => w.toJson()).toList(),
  };
}
