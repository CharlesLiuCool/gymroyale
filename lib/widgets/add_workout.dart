import 'package:flutter/material.dart';
import 'package:gymroyale/models/cardio_workout.dart';
import 'package:gymroyale/models/lift_workout.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/models/workout_activity.dart';
import '../app_colors.dart';

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

  // Cardio
  int _durationMinutes = 30;

  // Lift
  double _weight = 0;
  int _sets = 3;
  int _reps = 10;

  bool _saving = false;

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _saving = true);

    final repo = WorkoutRepository();
    final now = DateTime.now();

    if (_activityType == ActivityType.cardio) {
      final newWorkout = CardioWorkout(
        id: '',
        title: _title,
        startedAt: now,
        duration: Duration(minutes: _durationMinutes),
      );
      await repo.addWorkout(widget.userId, newWorkout);
    } else {
      final newWorkout = LiftWorkout(
        id: '',
        title: _title,
        startedAt: now,
        weight: _weight,
        sets: _sets,
        reps: _reps,
      );
      await repo.addWorkout(widget.userId, newWorkout);
    }

    widget.onWorkoutAdded();
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
              const Text(
                'Add Workout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                style: const TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  labelText: 'Workout Name',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accent),
                  ),
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
                dropdownColor: AppColors.card,
                decoration: InputDecoration(
                  labelText: 'Activity Type',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accent),
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                items:
                    ActivityType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.name,
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

              // Moving Time
              if (_activityType == ActivityType.cardio)
                TextFormField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    labelText: 'Duration (minutes)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textSecondary),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _durationMinutes = int.tryParse(value ?? '30') ?? 30;
                  },
                )
              else ...[
                TextFormField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    labelText: 'Weight (lbs)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textSecondary),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _weight = double.tryParse(value ?? '0') ?? 0;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    labelText: 'Sets',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textSecondary),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _sets = int.tryParse(value ?? '3') ?? 3;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    labelText: 'Reps',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textSecondary),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _reps = int.tryParse(value ?? '10') ?? 10;
                  },
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

              const SizedBox(height: 40), // Extra bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
