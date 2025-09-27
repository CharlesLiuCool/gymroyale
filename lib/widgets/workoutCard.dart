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
          Padding(padding: padding)
          // Stats row
          Padding(padding: padding)
          // Footer
          Padding(padding: padding)
        ],
      )
    );
  }
}