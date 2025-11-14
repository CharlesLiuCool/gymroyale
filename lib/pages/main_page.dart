import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/widgets/gym_checkin_button.dart';
import 'package:gymroyale/widgets/leaderboard.dart';
import '../widgets/workout_card.dart';
import '../app_colors.dart';

class MainPage extends StatefulWidget {
  final String userId;
  final LeaderboardRepository repo;

  const MainPage({super.key, required this.userId, required this.repo});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<WorkoutActivity> _workouts = [];
  bool _loadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
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

  /// Proper sign-out handling for Firebase + Google
  Future<void> _signOut() async {
    final googleSignIn = GoogleSignIn();

    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect(); // clear cached account
      }
    } catch (e) {
      debugPrint("Google disconnect error: $e");
    }

    await FirebaseAuth.instance.signOut();
    // NOTE: don't navigate manually
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leaderboard header
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Leaderboard(repo: widget.repo),
            ),

            // Workouts header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Workouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Workout list
            Expanded(
              child: Stack(
                children: [
                  _loadingWorkouts
                      ? const Center(child: CircularProgressIndicator())
                      : _workouts.isNotEmpty
                      ? ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: _workouts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final activity = _workouts[index];
                          return WorkoutCard(activity: activity);
                        },
                      )
                      : const Center(
                        child: Text(
                          'No workouts yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),

                  // Floating Add Button
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: AppColors.accent,
                      child: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (_) => AddWorkoutSheet(
                                userId: widget.userId,
                                onWorkoutAdded: _loadWorkouts,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Check-in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: GymCheckInButton(userId: widget.userId, repo: widget.repo),
            ),
          ],
        ),
      ),
    );
  }
}

class AddWorkoutSheet extends StatefulWidget {
  final String userId;
  final VoidCallback onWorkoutAdded;

  const AddWorkoutSheet({
    super.key,
    required this.userId,
    required this.onWorkoutAdded,
  });

  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  ActivityType _activityType = ActivityType.lift;
  Duration _movingTime = const Duration(minutes: 30);

  bool _saving = false;

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _saving = true);

    final newWorkout = WorkoutActivity(
      id: '',
      title: _title,
      activityType: _activityType,
      startedAt: DateTime.now(),
      movingTime: _movingTime,
      likeCount: 0,
      commentsCount: 0,
    );

    final repo = WorkoutRepository();
    await repo.addWorkout(widget.userId, newWorkout);

    widget.onWorkoutAdded();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Add Workout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              onSaved: (value) => _title = value ?? '',
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
            ),

            const SizedBox(height: 16),

            // Activity Type
            DropdownButtonFormField<ActivityType>(
              value: _activityType,
              decoration: const InputDecoration(
                labelText: 'Activity Type',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              items:
                  ActivityType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
              onChanged:
                  (value) => setState(
                    () => _activityType = value ?? ActivityType.lift,
                  ),
            ),

            const SizedBox(height: 16),

            // Moving Time
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Time Moving (minutes)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                final minutes = int.tryParse(value ?? '30') ?? 30;
                _movingTime = Duration(minutes: minutes);
              },
            ),

            const Spacer(),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saving ? null : _saveWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child:
                      _saving
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
