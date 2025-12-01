import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/widgets/leaderboard.dart';
import 'package:gymroyale/theme/app_colors.dart';
import 'package:gymroyale/widgets/add_friends.dart';

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

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _loadingFriends = true);
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();

      final data = doc.data();
      final friends = data?['friends'] as List<dynamic>? ?? [];

      setState(() {
        _friendIds = friends.map((f) => f.toString()).toList();
        _loadingFriends = false;
      });
    } catch (e) {
      setState(() => _loadingFriends = false);
      // optionally show error
      print("Failed to load friends: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Reload friends after coming back
          _loadFriends();
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
                      child: Leaderboard(repo: widget.repo),
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
                            filterIds: _friendIds, // pass friend IDs to filter
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
