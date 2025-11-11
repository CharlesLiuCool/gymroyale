import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymroyale/widgets/feed.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/models/workoutActivity.dart';
import 'package:gymroyale/widgets/gym_checkin_button.dart';
import 'package:gymroyale/widgets/leaderboard.dart'; // correct leaderboard import

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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Royale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: FeedPage(
        leaderboard: Leaderboard(repo: widget.repo), // pass leaderboard here
        workouts: _workouts,
      ),
      floatingActionButton: GymCheckInButton(
        userId: widget.userId,
        repo: widget.repo,
      ),
    );
  }
}
