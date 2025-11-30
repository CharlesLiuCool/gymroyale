import 'package:flutter/material.dart';
import 'package:gymroyale/models/cardio_workout.dart';
import 'package:gymroyale/models/lift_workout.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/models/workout_activity.dart';
import '../theme/app_colors.dart';

class AddWorkoutSheet extends StatefulWidget {
  final String userId;
  final VoidCallback onWorkoutAdded; // callback for add/edit
  final WorkoutActivity? workout; // null = add, non-null = edit

  const AddWorkoutSheet({
    super.key,
    required this.userId,
    required this.onWorkoutAdded,
    this.workout,
  });

  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  ActivityType _activityType = ActivityType.lift;

  // Cardio
  int _durationMinutes = 30;

  // Lift
  double _weight = 0;
  int _sets = 3;
  int _reps = 10;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _title = widget.workout!.title;
      _activityType = widget.workout!.activityType;
      if (_activityType == ActivityType.cardio &&
          widget.workout is CardioWorkout) {
        _durationMinutes = (widget.workout as CardioWorkout).duration.inMinutes;
      } else if (_activityType == ActivityType.lift &&
          widget.workout is LiftWorkout) {
        final lift = widget.workout as LiftWorkout;
        _weight = lift.weight;
        _sets = lift.sets;
        _reps = lift.reps;
      }
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _saving = true);

    final repo = WorkoutRepository();
    final now = DateTime.now();

    // Create workout instance
    if (_activityType == ActivityType.cardio) {
      final workout = CardioWorkout(
        id: widget.workout?.id ?? '', // preserve ID if editing
        title: _title,
        startedAt: now,
        duration: Duration(minutes: _durationMinutes),
      );
      if (widget.workout != null) {
        await repo.updateWorkout(widget.userId, workout);
      } else {
        await repo.addWorkout(widget.userId, workout);
      }
    } else {
      final workout = LiftWorkout(
        id: widget.workout?.id ?? '',
        title: _title,
        startedAt: now,
        weight: _weight,
        sets: _sets,
        reps: _reps,
      );
      if (widget.workout != null) {
        await repo.updateWorkout(widget.userId, workout);
      } else {
        await repo.addWorkout(widget.userId, workout);
      }
    }

    widget.onWorkoutAdded(); // ⚡ Use the correct callback
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Workout name
              TextFormField(
                initialValue: _title,
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
                onSaved: (value) => _title = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter a name' : null,
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
                    ActivityType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.name[0].toUpperCase() + type.name.substring(1),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(
                      () => _activityType = value ?? ActivityType.lift,
                    ),
              ),
              const SizedBox(height: 16),

              // Cardio or Lift fields
              if (_activityType == ActivityType.cardio)
                TextFormField(
                  initialValue: _durationMinutes.toString(),
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved:
                      (value) =>
                          _durationMinutes = int.tryParse(value ?? '30') ?? 30,
                )
              else ...[
                TextFormField(
                  initialValue: _weight.toString(),
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Weight (lbs)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved:
                      (value) => _weight = double.tryParse(value ?? '0') ?? 0,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _sets.toString(),
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Sets',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _sets = int.tryParse(value ?? '3') ?? 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _reps.toString(),
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _reps = int.tryParse(value ?? '10') ?? 10,
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
