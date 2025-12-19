import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class LeaderboardRow extends StatelessWidget {
  final User user;
  final int rank;
  final bool isCurrentUser;
  final bool isFriend;

  final VoidCallback onViewProfile;
  final VoidCallback onAddFriend;
  final VoidCallback onRemoveFriend;

  const LeaderboardRow({
    super.key,
    required this.user,
    required this.rank,
    required this.isCurrentUser,
    required this.isFriend,
    required this.onViewProfile,
    required this.onAddFriend,
    required this.onRemoveFriend,
  });

  void _showMenu(BuildContext context) {
    if (isCurrentUser) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.card,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.textPrimary),
                title: const Text(
                  'View Profile',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onViewProfile();
                },
              ),

              if (isFriend)
                ListTile(
                  leading: const Icon(
                    Icons.person_remove,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Remove Friend',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onRemoveFriend();
                  },
                )
              else
                ListTile(
                  leading: const Icon(
                    Icons.person_add,
                    color: Colors.greenAccent,
                  ),
                  title: const Text(
                    'Add Friend',
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onAddFriend();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isCurrentUser
                  ? AppColors.textPrimary.withOpacity(0.22)
                  : AppColors.card,
          borderRadius: BorderRadius.circular(5),
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

            // Name + Friend Icon
            Expanded(
              child: Row(
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  if (isFriend)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.person,
                        color: Colors.greenAccent,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),

            // Points + Streak
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
