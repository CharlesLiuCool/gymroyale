import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymroyale/pages/main/tabs/main_tab.dart';
import 'package:gymroyale/pages/main/tabs/progress_graph_tab.dart';
import 'package:gymroyale/pages/main/tabs/workout_tab.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/widgets/settings_menu.dart';
import 'package:gymroyale/pages/leaderboard/leaderboard_page.dart'; // <- NEW
import '../../widgets/navigation_menu.dart';
import '../../theme/app_colors.dart';

class MainPage extends StatefulWidget {
  final String userId;
  final LeaderboardRepository repo;

  const MainPage({super.key, required this.userId, required this.repo});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  List<WorkoutActivity> _workouts = [];
  bool _loadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  // TEMPORARY, OR FOR ANY UNIMPLEMENTED TABS
  Widget _comingSoon(String label) {
    return Center(
      child: Text(
        "$label (coming soon)",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _loadWorkouts() async {
    final workoutRepo = WorkoutRepository();
    final workouts = await workoutRepo.fetchUserWorkouts(widget.userId);
    if (mounted) {
      setState(() {
        _workouts = workouts;
        _loadingWorkouts = false;
      });
    }
  }

  Future<void> _deleteWorkout(String workoutId) async {
    final repo = WorkoutRepository();
    await repo.deleteWorkout(widget.userId, workoutId);
    setState(() {
      _workouts.removeWhere((w) => w.id == workoutId);
    });
  }

  Future<void> _signOut() async {
    final googleSignIn = GoogleSignIn();
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
    } catch (e) {
      debugPrint("Google disconnect error: $e");
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0.5,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/gym_royale_logo.png', height: 36),
            const SizedBox(width: 10),
            const Text(
              'Gym Royale',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: const [SettingsMenu()],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MainTab(userId: widget.userId, repo: widget.repo),
          LeaderboardPage(               // <- NEW TAB CONTENT
            userId: widget.userId,
            repo: widget.repo,
          ), // TAB 1
          WorkoutTab(userId: widget.userId),
          ProgressGraphTab(userId: widget.userId),
          _comingSoon("AI Help"), // TAB 4
        ],
      ),

      bottomNavigationBar: NavigationMenu(
        currentIndex: _selectedIndex,
        onItemTapped: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}