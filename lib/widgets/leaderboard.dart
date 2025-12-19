import 'package:flutter/material.dart';
import '../models/user.dart';
import 'leaderboard_row.dart';
import '../theme/app_colors.dart';
import 'package:gymroyale/pages/main/settings/profile_page.dart';
import 'dart:math' as math;

class Leaderboard extends StatefulWidget {
  final double initialHeight;
  final double expandedHeight;
  final dynamic repo;

  final User currentUser;

  final List<String>? filterIds;

  const Leaderboard({
    super.key,
    this.initialHeight = 180,
    this.expandedHeight = 400,
    required this.repo,
    required this.currentUser,
    this.filterIds,
  });

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  bool _expanded = false;
  final ScrollController _scrollController = ScrollController();

  void _toggleExpanded(List<User> users, double rowHeight) {
    setState(() => _expanded = !_expanded);

    if (_expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = users.indexWhere((u) => u.id == widget.currentUser.id);

        if (index != -1) {
          _scrollController.animateTo(
            index * rowHeight,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 60.0;

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

        final users =
            widget.filterIds != null
                ? snapshot.data!
                    .where((u) => widget.filterIds!.contains(u.id))
                    .toList()
                : snapshot.data!;

        if (users.isEmpty) {
          return const Center(
            child: Text(
              "No friends yet",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

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
                  controller: _scrollController,
                  physics:
                      _expanded
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isCurrent = user.id == widget.currentUser.id;

                    return SizedBox(
                      height: rowHeight,
                      child: LeaderboardRow(
                        user: user,
                        rank: index + 1,
                        isCurrentUser: isCurrent,
                        isFriend: widget.currentUser.friends.contains(user.id),

                        onViewProfile: () {
                          Navigator.push(
                            context,
                            // FUTURE: Replace with user-specific profile page
                            MaterialPageRoute(builder: (_) => ProfilePage()),
                          );
                        },

                        onAddFriend: () async {
                          await widget.repo.addFriend(
                            widget.currentUser.id,
                            user.id,
                          );
                        },

                        onRemoveFriend: () async {
                          await widget.repo.removeFriend(
                            widget.currentUser.id,
                            user.id,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            if (users.length >= 4)
              TextButton(
                onPressed: () => _toggleExpanded(users, rowHeight),
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
