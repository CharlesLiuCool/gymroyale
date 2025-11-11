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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 100),
                      child: leaderboard,
                    ),
                  ],
                ),
              ),
            ),

            if (!hasItems)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No workouts yet',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            if (hasItems)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: workouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = workouts[index];
                    return WorkoutCard(
                      activity: activity,
                    ); // Make sure WorkoutCard uses dark styling too
                  },
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
