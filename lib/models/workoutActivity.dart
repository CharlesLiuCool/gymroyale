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
}