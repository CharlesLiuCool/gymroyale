import 'package:flutter/material.dart';
import '../models/user.dart';

class LeaderboardRow extends StatelessWidget {
  final User user;

  const LeaderboardRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          255,
          116,
          197,
          255,
        ), // light blue background
        borderRadius: BorderRadius.circular(12), // rounded corners
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: ListTile(
        leading: Text(
          '#${user.rank}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        title: Text(user.name),
        trailing: Text(
          user.points.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
