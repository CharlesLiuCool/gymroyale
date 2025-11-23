import 'package:flutter/material.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/pages/main/main_page.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/theme/app_colors.dart';
import 'package:gymroyale/widgets/navigation_menu.dart';
import 'package:gymroyale/widgets/workout_card.dart'; // Import WorkoutCard

class WorkoutFeedPage extends StatefulWidget {
  final String userId;

  const WorkoutFeedPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<WorkoutFeedPage> createState() => _WorkoutFeedPageState();
}

class _WorkoutFeedPageState extends State<WorkoutFeedPage> {
  final WorkoutRepository _workoutRepo = WorkoutRepository();
  final List<WorkoutActivity> activities = [];
  bool _loading = true;

  int _selectedIndex = 1; // Set the default index for the Workout Feed page

  @override
  void initState() {
    super.initState();
    _loadWorkoutActivities();
  }

  Future<void> _loadWorkoutActivities() async {
    try {
      setState(() => _loading = true);

      final workouts = await _workoutRepo.fetchUserWorkouts(widget.userId);

      setState(() {
        activities.clear();
        activities.addAll(workouts);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load workouts: $e',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
    }
  }

  Future<void> _deleteWorkout(String workoutId) async {
    try {
      await _workoutRepo.deleteWorkout(widget.userId, workoutId);
      setState(() {
        activities.removeWhere((activity) => activity.id == workoutId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Workout deleted successfully.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete workout: $e',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the appropriate page
    switch (index) {
      case 0:
        // Navigate to MainPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MainPage(
                  userId: widget.userId,
                  repo: LeaderboardRepository(), // Pass the required repository
                ),
          ),
        );
        break;
      case 1:
        // Navigate to LeaderboardPage
        break;
      case 2:
        // Stay on WorkoutFeedPage
        break;
      case 3:
        // Navigate to ProgressGraphPage
        break;
      case 4:
        // Navigate to AIHelpPage
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Workout Feed',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
                : activities.isEmpty
                ? const Center(
                  child: Text(
                    'No workouts yet. Start tracking your progress!',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return WorkoutCard(
                      activity: activity,
                      onDelete:
                          () => _deleteWorkout(
                            activity.id,
                          ), // Pass delete callback
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          // Add workout functionality (e.g., navigate to a workout creation page)
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavigationMenu(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
