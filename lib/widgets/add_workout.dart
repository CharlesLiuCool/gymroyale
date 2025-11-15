import 'package:flutter/material.dart';
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
              TextFormField(
                style: const TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  labelText: 'Time Moving (minutes)',
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
                  final minutes = int.tryParse(value ?? '30') ?? 30;
                  _movingTime = Duration(minutes: minutes);
                },
              ),

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
