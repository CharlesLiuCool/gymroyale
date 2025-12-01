import 'package:flutter/material.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/theme/app_colors.dart';
import 'package:gymroyale/widgets/workout_card.dart';
import 'package:gymroyale/widgets/workout_form.dart'; // import the general form

class WorkoutTab extends StatelessWidget {
  final String userId;

  const WorkoutTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final repo = WorkoutRepository();

    return SafeArea(
      child: Stack(
        children: [
          StreamBuilder<List<WorkoutActivity>>(
            stream: repo.watchUserWorkouts(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              final activities = snapshot.data!;

              if (activities.isEmpty) {
                return const Center(
                  child: Text(
                    'No workouts yet. Start tracking your progress!',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];

                  return WorkoutCard(
                    activity: activity,
                    onDelete: () => repo.deleteWorkout(userId, activity.id),
                    onEdit: () {
                      // Open the general WorkoutForm for editing
                      showWorkoutSheet(
                        context,
                        userId,
                        workout: activity, // prefill the form
                        onSaved: () {
                          // StreamBuilder automatically updates
                        },
                      );
                    },
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
                // Open the general WorkoutForm for adding a new workout
                showWorkoutSheet(
                  context,
                  userId,
                  onSaved: () {
                    // StreamBuilder updates automatically
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
