import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { cardio, lift, blend }

class WorkoutActivity {
  final String id;
  final String title;
  final ActivityType activityType;
  final DateTime startedAt;
  final Duration movingTime;
  final int likeCount;
  final int commentsCount;

  const WorkoutActivity({
    required this.id,
    required this.title,
    required this.activityType,
    required this.startedAt,
    required this.movingTime,
    required this.likeCount,
    required this.commentsCount,
  });

  /// Create from Firestore map
  factory WorkoutActivity.fromMap(Map<String, dynamic> map, [String? id]) {
    return WorkoutActivity(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == map['activityType'],
        orElse: () => ActivityType.cardio,
      ),
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      movingTime: Duration(seconds: map['movingTime'] ?? 0),
      likeCount: map['likeCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'activityType': activityType.name,
      'startedAt': startedAt,
      'movingTime': movingTime.inSeconds,
      'likeCount': likeCount,
      'commentsCount': commentsCount,
    };
  }

  /// Create from JSON
  factory WorkoutActivity.fromJson(Map<String, dynamic> json) {
    return WorkoutActivity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == json['activityType'],
        orElse: () => ActivityType.cardio,
      ),
      startedAt: DateTime.parse(json['startedAt']),
      movingTime: Duration(seconds: json['movingTime']),
      likeCount: json['likeCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'activityType': activityType.name,
      'startedAt': startedAt.toIso8601String(),
      'movingTime': movingTime.inSeconds,
      'likeCount': likeCount,
      'commentsCount': commentsCount,
    };
  }

  /// Copy with updated fields
  WorkoutActivity copyWith({
    String? id,
    String? title,
    ActivityType? activityType,
    DateTime? startedAt,
    Duration? movingTime,
    int? likeCount,
    int? commentsCount,
  }) {
    return WorkoutActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      movingTime: movingTime ?? this.movingTime,
      likeCount: likeCount ?? this.likeCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
