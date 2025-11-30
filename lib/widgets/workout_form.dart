import 'package:flutter/material.dart';
import 'package:gymroyale/models/cardio_workout.dart';
import 'package:gymroyale/models/lift_workout.dart';
import 'package:gymroyale/repositories/workout_repository.dart';
import 'package:gymroyale/models/workout_activity.dart';
import '../theme/app_colors.dart';

class WorkoutForm extends StatefulWidget {
  final WorkoutActivity? workout;
  final void Function(WorkoutActivity) onSave;

  const WorkoutForm({super.key, this.workout, required this.onSave});

  @override
  State<WorkoutForm> createState() => _WorkoutFormState();
}

class _WorkoutFormState extends State<WorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  ActivityType _activityType = ActivityType.lift;

  int _durationMinutes = 30; // Cardio
  double _weight = 0; // Lift
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newWorkout =
        _activityType == ActivityType.cardio
            ? CardioWorkout(
              id: widget.workout?.id ?? '',
              title: _title,
              startedAt: DateTime.now(),
              duration: Duration(minutes: _durationMinutes),
            )
            : LiftWorkout(
              id: widget.workout?.id ?? '',
              title: _title,
              startedAt: DateTime.now(),
              weight: _weight,
              sets: _sets,
              reps: _reps,
            );

    widget.onSave(newWorkout);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Workout Name'),
              onSaved: (v) => _title = v ?? '',
              validator:
                  (v) => (v == null || v.isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ActivityType>(
              value: _activityType,
              items:
                  ActivityType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.name[0].toUpperCase() + type.name.substring(1),
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  (v) => setState(() => _activityType = v ?? ActivityType.lift),
            ),
            const SizedBox(height: 16),
            if (_activityType == ActivityType.cardio)
              TextFormField(
                initialValue: _durationMinutes.toString(),
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                onSaved:
                    (v) => _durationMinutes = int.tryParse(v ?? '30') ?? 30,
              )
            else ...[
              TextFormField(
                initialValue: _weight.toString(),
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _weight = double.tryParse(v ?? '0') ?? 0,
              ),
              TextFormField(
                initialValue: _sets.toString(),
                decoration: const InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _sets = int.tryParse(v ?? '3') ?? 3,
              ),
              TextFormField(
                initialValue: _reps.toString(),
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _reps = int.tryParse(v ?? '10') ?? 10,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

void showWorkoutSheet(
  BuildContext context,
  String userId, {
  WorkoutActivity? workout,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final repo = WorkoutRepository();
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: WorkoutForm(
            workout: workout,
            onSave: (workoutData) async {
              if (workout != null) {
                await repo.updateWorkout(userId, workoutData);
              } else {
                await repo.addWorkout(userId, workoutData);
              }
              Navigator.of(sheetContext).pop();
            },
          ),
        ),
      );
    },
  );
}
