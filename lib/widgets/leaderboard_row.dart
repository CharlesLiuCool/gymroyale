import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class LeaderboardRow extends StatelessWidget {
  final User user;
  final int rank; // dynamically passed in

  const LeaderboardRow({super.key, required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            child: Text(
              '$rank', // use dynamic rank
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '${user.points} pts',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              if (user.streakCount != null && user.streakCount! > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.streakCount}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
