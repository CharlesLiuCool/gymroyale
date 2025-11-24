import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const NavigationMenu({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemTapped,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed, // ensure all items show
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main'),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Workouts',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline),
          label: 'AI Help',
        ),
      ],
    );
  }
}
