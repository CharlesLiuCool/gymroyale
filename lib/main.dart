import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'repositories/leaderboard_repository.dart';
import 'pages/main_page.dart';
import 'app_colors.dart';

Future<void> main() async {
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.card,
        primaryColor: AppColors.accent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: AuthGate(repo: repo),
    );
  }
}

/// Decides whether to show LoginPage or MainPage
class AuthGate extends StatelessWidget {
  final LeaderboardRepository repo;
  const AuthGate({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for Firebase to initialize
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // User is signed in
          return MainPage(userId: user.uid, repo: repo);
        } else {
          // User is NOT signed in
          return const LoginPage();
        }
      },
    );
  }
}
