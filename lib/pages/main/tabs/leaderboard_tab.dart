import 'package:flutter/material.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/widgets/leaderboard.dart';
import 'package:gymroyale/theme/app_colors.dart';
import 'package:gymroyale/widgets/add_friends.dart';
import 'package:gymroyale/models/user.dart';

class LeaderboardTab extends StatefulWidget {
  final String userId;
  final LeaderboardRepository repo;

  const LeaderboardTab({super.key, required this.userId, required this.repo});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  List<String> _friendIds = [];
  bool _loadingFriends = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // reactive listener handles both current user and friends
  }

  /// Listen to the current user's document in real-time
  void _loadCurrentUser() {
    widget.repo.watchUser(widget.userId).listen((user) {
      if (user == null) return;

      setState(() {
        _currentUser = user;
        _friendIds = [
          widget.userId, // include self
          ...user.friends,
        ];
        _loadingFriends = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddFriendsPage(userId: widget.userId),
            ),
          );
          // No need to reload friends manually; listener updates automatically
        },
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2, // Global + Friends
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TabBar(
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.accent,
                  tabs: [Tab(text: 'Global'), Tab(text: 'Friends')],
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    // GLOBAL TAB
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Leaderboard(
                        repo: widget.repo,
                        currentUser: _currentUser!,
                      ),
                    ),

                    // FRIENDS TAB
                    _loadingFriends
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Leaderboard(
                            repo: widget.repo,
                            currentUser: _currentUser!,
                            filterIds: _friendIds, // filter friend IDs
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
