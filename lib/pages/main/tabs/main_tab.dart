import 'package:flutter/material.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/widgets/add_workout.dart';
import 'package:gymroyale/widgets/gym_checkin_button.dart';
import 'package:gymroyale/widgets/leaderboard.dart';
import 'package:gymroyale/widgets/workout_card.dart';
import 'package:gymroyale/theme/app_colors.dart';

class MainTab extends StatelessWidget {
  final String userId;
  final LeaderboardRepository repo;

  const MainTab({super.key, required this.userId, required this.repo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- LEADERBOARD ----------
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Leaderboard(repo: repo),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: GymCheckInButton(userId: userId, repo: repo),
          ),

          // ---------- WORKOUT SECTION ----------
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Workouts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<WorkoutActivity>>(
                  stream: WorkoutRepository().watchUserWorkouts(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      );
                    }

                    final workouts = snapshot.data!;

                    if (workouts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No workouts yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      key: const PageStorageKey("main_tab_workouts"),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: workouts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final activity = workouts[index];
                        return WorkoutCard(
                          activity: activity,
                          onDelete:
                              () => WorkoutRepository().deleteWorkout(
                                userId,
                                activity.id,
                              ),
                        );
                      },
                    );
                  },
                ),

                // ---------- ADD WORKOUT BUTTON ----------
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.accent,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (_) => AddWorkoutSheet(
                              userId: userId,
                              onWorkoutAdded: () {}, // no reload needed anymore
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
