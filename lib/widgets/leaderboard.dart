import 'package:flutter/material.dart';
import '../models/user.dart';
import 'leaderboard_row.dart';
import '../app_colors.dart';
import 'dart:math' as math;

class Leaderboard extends StatefulWidget {
  final double initialHeight; // small initial height
  final double expandedHeight; // height when expanded
  final dynamic repo;

  const Leaderboard({
    super.key,
    this.initialHeight = 180,
    this.expandedHeight = 400,
    this.repo,
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
    // Temporary test users
    final users = List<User>.generate(
      10,
      (index) => User(
        id: 'user$index',
        name: 'User ${index + 1}',
        points: (10 - index) * 10,
        rank: index + 1,
      ),
    );

    final rowHeight = 60.0;
    final calculatedHeight = users.length * rowHeight;

    final containerHeight =
        _expanded
            ? math.min(calculatedHeight, widget.expandedHeight)
            : widget.initialHeight;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: containerHeight,
          decoration: BoxDecoration(
            color: AppColors.background,
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

        // Show More / Collapse button
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
  }
}
