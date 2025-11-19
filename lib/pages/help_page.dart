import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              'Welcome to Gym Royale Help!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Here are some common questions and tips:',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24),
            HelpItem(
              title: 'How do I log workouts?',
              description:
                  'Tap the "+" button on the main page to add a workout. Fill out the form and hit Save.',
            ),
            HelpItem(
              title: 'How does the leaderboard work?',
              description:
                  'Points are awarded based on check-ins and workouts. The leaderboard updates in real time.',
            ),
            HelpItem(
              title: 'Can I edit or delete a workout?',
              description:
                  'Currently, workouts cannot be edited or deleted. This feature is coming soon!',
            ),
            HelpItem(
              title: 'Need more help?',
              description:
                  'Reach out to charles.liu.college@gmail.com with concerns, questions, or suggestions.',
            ),
          ],
        ),
      ),
    );
  }
}

class HelpItem extends StatelessWidget {
  final String title;
  final String description;

  const HelpItem({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
