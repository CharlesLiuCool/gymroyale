import 'package:flutter/material.dart';
import '../models/workoutActivity.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutActivity activity;
  const WorkoutCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      clipBehavior: Clip.hardEdge,
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
                  backgroundColor: cs.primaryContainer,
                  child: Icon(
                    _iconFor(activity.activityType)
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Text(_friendlyDate(activity.startedAt), 
                          style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.more_horiz, color:cs.onSurfaceVariant),
              ],
            ),
          ),
          // Stats row add extra data here as we decide
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: StatChip(
                    label: 'Time moving',
                    value: _formatDuration(activity.movingTime)
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.favorite_border, 
                  label: '${activity.likeCount}'
                ),
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.mode_comment_outlined, 
                  label: '${activity.commentsCount}'
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share), 
                  label: const Text('Share')
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Subcomponent
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  const StatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: cs.onSurface),
      label: Text(label, style: TextStyle(color: cs.onSurface)),
      style: TextButton.styleFrom(
        foregroundColor: cs.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
    case ActivityType.blend:
      return Icons.fitbit;
  }
}

String _friendlyDate(DateTime dt) {
  final now = DateTime.now();
  final sameDay = now.year == dt.year && now.month == dt.month && now.day == dt.day;
  if (sameDay) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return 'Today • $h:$m $ap';
  }
  return '${_month(dt.month)} ${dt.day}, ${dt.year}';
}

String _month(int m) =>
    const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
}