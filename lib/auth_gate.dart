import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/username_setup_page.dart';
import 'repositories/leaderboard_repository.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) return const LoginPage();

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final doc = snapshot.data;
            final data = doc?.data() as Map<String, dynamic>?;
            final username = data?['name']?.toString().trim() ?? '';

            if (username.isEmpty) {
              // New user → username setup
              return UsernameSetupPage(
                userId: user.uid,
                repo: LeaderboardRepository(),
              );
            }

            // Returning user → main page
            return MainPage(userId: user.uid, repo: LeaderboardRepository());
          },
        );
      },
    );
  }
}
