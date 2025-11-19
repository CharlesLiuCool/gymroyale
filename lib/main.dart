import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymroyale/models/workoutActivity.dart';
import 'package:gymroyale/widgets/workoutCard.dart';
import 'firebase_options.dart';
import 'repositories/leaderboard_repository.dart';
import 'widgets/leaderboard.dart';
import 'widgets/gym_checkin_button.dart';
import 'widgets/workout_tracking_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = LeaderboardRepository();

    final activity = WorkoutActivity(
      id: 'a1',
      title: 'Evening lift',
      activityType: ActivityType.lift,
      startedAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 12)),
      movingTime: const Duration(minutes: 42, seconds: 10),
      likeCount: 12,
      commentsCount: 3,
    );

    final activity2 = WorkoutActivity(
      id: 'a2',
      title: 'Afternoon Treadmill',
      activityType: ActivityType.cardio,
      startedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      movingTime: const Duration(minutes: 15, seconds: 30),
      likeCount: 30,
      commentsCount: 5,
    );

    final activity3 = WorkoutActivity(
      id: 'a3',
      title: 'Morning workout + run',
      activityType: ActivityType.blend,
      startedAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
      movingTime: const Duration(hours: 1, minutes: 15, seconds: 23),
      likeCount: 60,
      commentsCount: 15,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Royale',
      routes: {
        WorkoutTrackingPage.route: (context) => const WorkoutTrackingPage(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  tooltip: 'Track Workout',
                  icon: const Icon(Icons.fitness_center),
                  onPressed: () {
                    print("DUMBBELL PRESSED");

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WorkoutTrackingPage(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            Leaderboard(repo: repo),
            WorkoutCard(activity: activity),
            WorkoutCard(activity: activity2),
            WorkoutCard(activity: activity3),
          ],
        ),
        floatingActionButton: GymCheckInButton(
          userId: 'UserIdHere',
          repo: repo,
        ),
      ),
    );
  }
}
