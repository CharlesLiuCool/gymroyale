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
                    Icons.fitness_center, color: cs.onPrimary
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
                      Text(activity.startedAt.toString(), 
                          style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.more_horiz, color:cs.onSurfaceVariant),
              ],
            ),
          ),
          // Stats row
          //Padding(padding: padding),
          // Footer
          //Padding(padding: padding),
        ],
      ),
    );
  }
}