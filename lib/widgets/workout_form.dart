import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymroyale/models/cardio_workout.dart';
import 'package:gymroyale/models/lift_workout.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import '../theme/app_colors.dart';

class WorkoutSheet extends StatefulWidget {
  final String userId;
  final VoidCallback onWorkoutSaved;
  final WorkoutActivity? workout;

  const WorkoutSheet({
    super.key,
    required this.userId,
    required this.onWorkoutSaved,
    this.workout,
  });

  @override
  State<WorkoutSheet> createState() => _WorkoutSheetState();
}

class _WorkoutSheetState extends State<WorkoutSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loadingDefaults = true;

  // Controllers
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();

  ActivityType _activityType = ActivityType.lift;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  Future<void> _initValues() async {
    if (widget.workout != null) {
      // Editing existing workout
      _titleController.text = widget.workout!.title;
      _activityType = widget.workout!.activityType;

      if (_activityType == ActivityType.cardio &&
          widget.workout is CardioWorkout) {
        _durationController.text =
            (widget.workout as CardioWorkout).duration.inMinutes.toString();
      } else if (_activityType == ActivityType.lift &&
          widget.workout is LiftWorkout) {
        final lift = widget.workout as LiftWorkout;
        _weightController.text = lift.weight.toString();
        _setsController.text = lift.sets.toString();
        _repsController.text = lift.reps.toString();
      }
    } else {
      // Adding new workout → fetch user defaults
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();
      final data = doc.data();

      _titleController.text = '';
      _weightController.text = (data?['defaultLiftWeight'] ?? 0).toString();
      _setsController.text = (data?['defaultLiftSets'] ?? 3).toString();
      _repsController.text = (data?['defaultLiftReps'] ?? 10).toString();
      _durationController.text =
          (data?['defaultCardioDuration'] ?? 30).toString();

      // Default activity type for new workouts
      _activityType = ActivityType.lift;
    }

    setState(() => _loadingDefaults = false);
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);

    final repo = WorkoutRepository();
    final now = DateTime.now();

    if (_activityType == ActivityType.cardio) {
      final workout = CardioWorkout(
        id: widget.workout?.id ?? '',
        title: _titleController.text,
        startedAt: now,
        duration: Duration(
          minutes: int.tryParse(_durationController.text) ?? 30,
        ),
      );
      if (widget.workout != null) {
        await repo.updateWorkout(widget.userId, workout);
      } else {
        await repo.addWorkout(widget.userId, workout);
      }
    } else {
      final workout = LiftWorkout(
        id: widget.workout?.id ?? '',
        title: _titleController.text,
        startedAt: now,
        weight: double.tryParse(_weightController.text) ?? 0,
        sets: int.tryParse(_setsController.text) ?? 3,
        reps: int.tryParse(_repsController.text) ?? 10,
      );
      if (widget.workout != null) {
        await repo.updateWorkout(widget.userId, workout);
      } else {
        await repo.addWorkout(widget.userId, workout);
      }
    }

    widget.onWorkoutSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDefaults) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.workout == null ? 'Add Workout' : 'Edit Workout',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              // Workout name
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.accent,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accent),
                  ),
                ),
                validator:
                    (v) => (v == null || v.isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              // Activity type
              DropdownButtonFormField<ActivityType>(
                value: _activityType,
                dropdownColor: AppColors.card,
                decoration: const InputDecoration(
                  labelText: 'Activity Type',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accent),
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                items:
                    ActivityType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.name[0].toUpperCase() +
                                  type.name.substring(1),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  setState(() {
                    _activityType = v ?? ActivityType.lift;
                    // Reset fields when switching activity
                    if (_activityType == ActivityType.cardio) {
                      _durationController.text =
                          _durationController.text.isEmpty
                              ? '30'
                              : _durationController.text;
                    } else {
                      _weightController.text =
                          _weightController.text.isEmpty
                              ? '0'
                              : _weightController.text;
                      _setsController.text =
                          _setsController.text.isEmpty
                              ? '3'
                              : _setsController.text;
                      _repsController.text =
                          _repsController.text.isEmpty
                              ? '10'
                              : _repsController.text;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              // Cardio or Lift fields
              if (_activityType == ActivityType.cardio)
                TextFormField(
                  controller: _durationController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                )
              else ...[
                TextFormField(
                  controller: _weightController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Weight (lbs)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _setsController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Sets',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _repsController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 32),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child:
                        _saving
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                            : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to open the sheet
void showWorkoutSheet(
  BuildContext context,
  String userId, {
  WorkoutActivity? workout,
  required VoidCallback onSaved,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: WorkoutSheet(
            userId: userId,
            workout: workout,
            onWorkoutSaved: onSaved,
          ),
        ),
  );
}
