import 'package:flutter/material.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/widgets/leaderboard.dart';
import 'package:gymroyale/theme/app_colors.dart';

class LeaderboardPage extends StatelessWidget {
  final String userId;
  final LeaderboardRepository repo;

  const LeaderboardPage({
    super.key,
    required this.userId,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2, // Global + Friends
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
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

            // Tabs: Global / Friends
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accent,
                tabs: [
                  Tab(text: 'Global'),
                  Tab(text: 'Friends'),
                ],
              ),
            ),

            // Tab contents
            Expanded(
              child: TabBarView(
                children: [
                  // GLOBAL TAB – existing leaderboard
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Leaderboard(repo: repo),
                  ),

                  // FRIENDS TAB – TODO: filter by friends later
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Leaderboard(repo: repo),
                    // Later we’ll replace this with a friends-only stream.
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}