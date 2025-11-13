import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/models/workoutActivity.dart';
import 'package:gymroyale/widgets/gym_checkin_button.dart';
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
  late final List<WorkoutActivity> _workouts;

  @override
  void initState() {
    super.initState();
    _workouts = [
      WorkoutActivity(
        id: 'a1',
        title: 'Evening Lift',
        activityType: ActivityType.lift,
        startedAt: DateTime.now().subtract(
          const Duration(hours: 3, minutes: 12),
        ),
        movingTime: const Duration(minutes: 42, seconds: 10),
        likeCount: 12,
        commentsCount: 3,
      ),
      WorkoutActivity(
        id: 'a2',
        title: 'Afternoon Treadmill',
        activityType: ActivityType.cardio,
        startedAt: DateTime.now().subtract(
          const Duration(hours: 2, minutes: 30),
        ),
        movingTime: const Duration(minutes: 15, seconds: 30),
        likeCount: 30,
        commentsCount: 5,
      ),
      WorkoutActivity(
        id: 'a3',
        title: 'Morning Workout + Run',
        activityType: ActivityType.blend,
        startedAt: DateTime.now().subtract(
          const Duration(hours: 4, minutes: 45),
        ),
        movingTime: const Duration(hours: 1, minutes: 15, seconds: 23),
        likeCount: 60,
        commentsCount: 15,
      ),
    ];
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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
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
              child:
                  _workouts.isNotEmpty
                      ? ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
