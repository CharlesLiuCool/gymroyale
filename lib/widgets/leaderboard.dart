import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/leaderboard_repository.dart';
import 'leaderboard_row.dart';

class Leaderboard extends StatefulWidget {
  final LeaderboardRepository repo;

  const Leaderboard({super.key, required this.repo});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: widget.repo.topUsers(), // get live data from Firebase
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users yet'));
        }

        final users = snapshot.data!;

        // Optional: assign rank based on index
        for (var i = 0; i < users.length; i++) {
          users[i] = User(
            id: users[i].id,
            name: users[i].name,
            points: users[i].points,
            rank: i + 1,
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return LeaderboardRow(user: user);
          },
        );
      },
    );
  }
}
