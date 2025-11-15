import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/widgets/gym_checkin_button.dart';
import 'package:gymroyale/widgets/add_workout.dart';
import 'package:gymroyale/widgets/leaderboard.dart';
import '../widgets/workout_card.dart';
import '../app_colors.dart';

class MainPage extends StatefulWidget {
  final String userId;
  final LeaderboardRepository repo;

  const MainPage({super.key, required this.userId, required this.repo});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<WorkoutActivity> _workouts = [];
  bool _loadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workoutRepo = WorkoutRepository();
    final workouts = await workoutRepo.fetchUserWorkouts(widget.userId);
    if (mounted) {
      setState(() {
        _workouts = workouts;
        _loadingWorkouts = false;
      });
    }
  }

  /// Proper sign-out handling for Firebase + Google
  Future<void> _signOut() async {
    final googleSignIn = GoogleSignIn();

    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect(); // clear cached account
      }
    } catch (e) {
      debugPrint("Google disconnect error: $e");
    }

    await FirebaseAuth.instance.signOut();
    // NOTE: don't navigate manually
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0.5,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/gym_royale_logo.png', height: 36),
            const SizedBox(width: 10),
            const Text(
              'Gym Royale',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onSelected: (value) {
              switch (value) {
                case 'signout':
                  _signOut();
                  break;
                case 'profile':
                  // TODO: Navigate to profile page
                  break;
                case 'help':
                  // TODO: Show help dialog
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'profile', child: Text('Profile')),
                  const PopupMenuItem(value: 'help', child: Text('Help')),
                  const PopupMenuItem(
                    value: 'signout',
                    child: Text('Sign Out'),
                  ),
                ],
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leaderboard header
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
              child: Leaderboard(repo: widget.repo),
            ),

            // Workouts header
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

            // Workout list
            Expanded(
              child: Stack(
                children: [
                  _loadingWorkouts
                      ? const Center(child: CircularProgressIndicator())
                      : _workouts.isNotEmpty
                      ? ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: _workouts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final activity = _workouts[index];
                          return WorkoutCard(activity: activity);
                        },
                      )
                      : const Center(
                        child: Text(
                          'No workouts yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),

                  // Floating Add Button
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
                                userId: widget.userId,
                                onWorkoutAdded: _loadWorkouts,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Check-in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: GymCheckInButton(userId: widget.userId, repo: widget.repo),
            ),
          ],
        ),
      ),
    );
  }
}
