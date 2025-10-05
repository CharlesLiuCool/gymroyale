import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'repositories/leaderboard_repository.dart';
import 'widgets/leaderboard.dart';
import 'widgets/gym_checkin_button.dart';

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Gym Royale',

      home: Scaffold(
        appBar: AppBar(title: const Text('Leaderboard')),
        body: Leaderboard(repo: repo),
        // FUTURE: Update UserId to be unique per person (perhaps set it as username?)
        floatingActionButton: GymCheckInButton(
          userId: 'UserIdHere',
          repo: repo,
        ),
      ),
    );
  }
}
