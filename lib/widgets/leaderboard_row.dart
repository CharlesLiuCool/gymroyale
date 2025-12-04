import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class LeaderboardRow extends StatelessWidget {
  final User user;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardRow({
    super.key,
    required this.user,
    required this.rank,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? AppColors.textPrimary.withOpacity(0.22) // subtle highlight
                : AppColors.card,
        borderRadius: BorderRadius.circular(5),
        boxShadow:
            isCurrentUser
                ? [
                  BoxShadow(
                    color: AppColors.textPrimary.withOpacity(0.15),
                    blurRadius: 2,
                    spreadRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ]
                : [],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            child: Text(
              '$rank',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              user.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
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
