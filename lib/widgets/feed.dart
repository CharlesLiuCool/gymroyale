import 'package:flutter/material.dart';
import 'package:gymroyale/models/workoutActivity.dart';
import '../widgets/workoutCard.dart';

class FeedPage extends StatelessWidget {
  final Widget leaderboard; // any widget (e.g. your leaderboard)
  final List<WorkoutActivity> workouts; // workout data list

  const FeedPage({
    super.key,
    required this.leaderboard,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = workouts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Leaderboard at the top
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              sliver: SliverToBoxAdapter(child: leaderboard),
            ),

            // Empty state (optional)
            if (!hasItems)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No workouts yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),

            // Workout feed
            if (hasItems)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: workouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = workouts[index];
                    return WorkoutCard(activity: activity);
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