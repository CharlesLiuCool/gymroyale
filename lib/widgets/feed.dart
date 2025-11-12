import 'package:flutter/material.dart';
import 'package:gymroyale/models/workoutActivity.dart';
import 'workout_card.dart';
import '../app_colors.dart';

class FeedPage extends StatelessWidget {
  final Widget leaderboard;
  final List<WorkoutActivity> workouts;

  const FeedPage({
    super.key,
    required this.leaderboard,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = workouts.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text(
          'Feed',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Leaderboard with max height
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: leaderboard,
            ),

            // Workout list fills remaining space
            Expanded(
              child:
                  hasItems
                      ? ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: workouts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final activity = workouts[index];
                          return WorkoutCard(activity: activity);
                        },
                      )
                      : Center(
                        child: Text(
                          'No workouts yet',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
