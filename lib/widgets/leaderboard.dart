import 'package:flutter/material.dart';
import '../models/user.dart';
import 'leaderboard_row.dart';
import '../app_colors.dart';
import 'dart:math' as math;

class Leaderboard extends StatefulWidget {
  final double initialHeight;
  final double expandedHeight;
  final dynamic repo;

  const Leaderboard({
    super.key,
    this.initialHeight = 180,
    this.expandedHeight = 400,
    required this.repo,
  });

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rowHeight = 60.0;

    return StreamBuilder<List<User>>(
      stream: widget.repo.topUsers(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No users yet",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        // Create a ranked list without mutating `User`
        final users = List<User>.generate(
          snapshot.data!.length,
          (i) => snapshot.data![i].copyWith(rank: i + 1),
        );

        final calculatedHeight = users.length * rowHeight;
        final containerHeight =
            _expanded
                ? math.min(calculatedHeight, widget.expandedHeight)
                : widget.initialHeight;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: containerHeight,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  physics:
                      _expanded
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return SizedBox(
                      height: rowHeight,
                      child: LeaderboardRow(user: user),
                    );
                  },
                ),
              ),
            ),

            if (users.length >= 4)
              TextButton(
                onPressed: _toggleExpanded,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? "Show Less" : "Show More",
                      style: const TextStyle(color: AppColors.accent),
                    ),
                    Icon(
                      _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
