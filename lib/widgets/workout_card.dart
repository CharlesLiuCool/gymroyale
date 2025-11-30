import 'package:flutter/material.dart';
import 'package:gymroyale/models/cardio_workout.dart';
import 'package:gymroyale/models/lift_workout.dart';
import '../models/workout_activity.dart';
import '../theme/app_colors.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutActivity activity;
  final VoidCallback onDelete;
  final VoidCallback? onEdit; // optional callback for edit

  const WorkoutCard({
    super.key,
    required this.activity,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accent,
                  child: Icon(
                    _iconFor(activity.activityType),
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _friendlyDate(activity.startedAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      if (onEdit != null) onEdit!();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: const [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                if (activity is CardioWorkout)
                  Expanded(
                    child: StatChip(
                      label: 'Duration',
                      value: _formatDuration(
                        (activity as CardioWorkout).duration,
                      ),
                    ),
                  )
                else if (activity is LiftWorkout) ...[
                  Expanded(
                    child: StatChip(
                      label: 'Weight',
                      value: '${(activity as LiftWorkout).weight} lbs',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatChip(
                      label: 'Sets',
                      value: '${(activity as LiftWorkout).sets}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatChip(
                      label: 'Reps',
                      value: '${(activity as LiftWorkout).reps}',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  const StatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(ActivityType t) {
  switch (t) {
    case ActivityType.lift:
      return Icons.fitness_center;
    case ActivityType.cardio:
      return Icons.directions_run;
  }
}

String _friendlyDate(DateTime dt) {
  final now = DateTime.now();
  final sameDay =
      now.year == dt.year && now.month == dt.month && now.day == dt.day;

  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12; // Convert to 12-hour format
  final m = dt.minute.toString().padLeft(2, '0'); // Add leading zero to minutes
  final ap = dt.hour >= 12 ? 'PM' : 'AM'; // Determine AM/PM

  final time = '$h:$m $ap'; // Format time as hh:mm AM/PM

  if (sameDay) {
    return 'Today • $time';
  }

  return '${_month(dt.month)} ${dt.day}, ${dt.year} • $time';
}

String _month(int m) =>
    const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][m - 1];

String _formatDuration(Duration? d) {
  if (d == null) return '—';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
}
