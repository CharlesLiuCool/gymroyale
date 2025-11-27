import 'package:flutter/material.dart';
import 'pages/main/main_page.dart';
import 'repositories/leaderboard_repository.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMPORARY: bypass Firebase auth + login flow
    return MainPage(
      userId: 'debug-user',
      repo: LeaderboardRepository(),
    );
  }
}