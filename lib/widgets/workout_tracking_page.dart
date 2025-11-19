import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});
  static const route = '/track';

  @override
  State<WorkoutTrackingPage> createState() => _WorkoutTrackingPageState();
}

class _WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  bool inProgress = false;

  // Demo state for one example exercise + sets (you’ll replace with Firestore later)
  final List<_Exercise> exercises = [
    _Exercise(
      name: 'Barbell Squat',
      sets: [
        _SetEntry(weight: 135, reps: 8, rpe: 7.5),
        _SetEntry(weight: 185, reps: 5, rpe: 8.0),
      ],
    ),
  ];

  Future<void> _saveWorkout() async {
    // 1. Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save workouts.')),
      );
      return;
    }

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise first.')),
      );
      return;
    }

    try {
      // 2. Build workout payload
      final workoutData = <String, dynamic>{
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'inProgress': inProgress,
        'exercises': exercises.map((e) {
          return {
            'name': e.name,
            'weightLabel': e.weightLabel,
            'repsLabel': e.repsLabel,
            'rpeLabel': e.rpeLabel,
            'sets': e.sets.map((s) {
              return {
                'weight': s.weight,
                'reps': s.reps,
                'rpe': s.rpe,
              };
            }).toList(),
          };
        }).toList(),
      };

      // 3. Write to Firestore
      await FirebaseFirestore.instance
          .collection('workouts')
          .add(workoutData);

      // 4. Reset state / give feedback
      setState(() {
        inProgress = false;
        // Optional: clear exercises or keep them
        // exercises.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        title: const Text('Track Workout'),
        actions: [
          TextButton(
            onPressed: () => setState(() => inProgress = !inProgress),
            child: Text(
              inProgress ? 'Finish' : 'Start',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Add exercise',
                  onPressed: () {
                    setState(() {
                      exercises.add(
                        _Exercise(name: 'New Exercise', sets: []),
                      );
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            // Exercise list
            ...exercises.map(
              (ex) => _ExerciseCard(
                exercise: ex,
                onAddSet: () {
                  setState(() {
                    ex.sets.add(_SetEntry(weight: 0, reps: 0, rpe: 0));
                  });
                },
                onDelete: () {
                  setState(() {
                    exercises.remove(ex);
                  });
                },
              ),
            ),

            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
              onPressed: () async => await _saveWorkout(),
              icon: const Icon(Icons.save),
              label: const Text('Save workout'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool inProgress;
  const _StatusCard({required this.inProgress});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(inProgress ? Icons.timer : Icons.play_circle_outline),
        title: Text(inProgress ? 'In progress' : 'Not started'),
        subtitle: Text(
          inProgress ? 'Tap Finish when done' : 'Tap Start to begin',
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final _Exercise exercise;
  final VoidCallback onAddSet;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.exercise,
    required this.onAddSet,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade900, //Edited the exercise card widget color....
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name row (editable) + delete
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.name,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.white, //Changed the text color to white for readability
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (value) {
                      exercise.name = value;
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Delete exercise',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Sets table-ish
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header row (editable labels)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const _Cell(label: '#', flex: 2, isHeader: true),
                        _EditableHeaderCell(
                          flex: 4,
                          value: exercise.weightLabel,
                          onChanged: (v) => exercise.weightLabel = v,
                        ),
                        _EditableHeaderCell(
                          flex: 3,
                          value: exercise.repsLabel,
                          onChanged: (v) => exercise.repsLabel = v,
                        ),
                        _EditableHeaderCell(
                          flex: 3,
                          value: exercise.rpeLabel,
                          onChanged: (v) => exercise.rpeLabel = v,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Data rows
                  ...List.generate(exercise.sets.length, (i) {
                    final s = exercise.sets[i];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              _Cell(label: '${i + 1}', flex: 2),
                              _EditableNumberCell(
                                flex: 4,
                                value: s.weight?.toString() ?? '',
                                hint: 'lb/kg',
                                onChanged: (v) =>
                                    s.weight = double.tryParse(v),
                              ),
                              _EditableNumberCell(
                                flex: 3,
                                value: s.reps?.toString() ?? '',
                                hint: 'reps',
                                onChanged: (v) =>
                                    s.reps = int.tryParse(v),
                              ),
                              _EditableNumberCell(
                                flex: 3,
                                value: s.rpe?.toString() ?? '',
                                hint: 'RPE',
                                onChanged: (v) =>
                                    s.rpe = double.tryParse(v),
                              ),
                            ],
                          ),
                        ),
                        if (i != exercise.sets.length - 1)
                          const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: const Text('Add set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final int flex;
  final bool isHeader;

  const _Cell({
    required this.label,
    required this.flex,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)
        : const TextStyle(color: Colors.white70);
    return Expanded(
      flex: flex,
      child: Text(label, style: style),
    );
  }
}

/// Editable numeric cell (for Weight / Reps / RPE values)
class _EditableNumberCell extends StatelessWidget {
  final int flex;
  final String value;
  final String hint;
  final void Function(String) onChanged;

  const _EditableNumberCell({
    required this.flex,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: TextFormField(
        initialValue: value,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54,),
          filled: true,
          fillColor: Colors.blueGrey.shade800,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// Editable header cell (for Weight / Reps / RPE labels)
class _EditableHeaderCell extends StatelessWidget {
  final int flex;
  final String value;
  final void Function(String) onChanged;

  const _EditableHeaderCell({
    required this.flex,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: TextFormField(
        initialValue: value,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _Exercise {
  _Exercise({
    required this.name,
    required this.sets,
    this.weightLabel = 'Weight',
    this.repsLabel = 'Reps',
    this.rpeLabel = 'RPE',
  });

  String name;

  // Column labels
  String weightLabel;
  String repsLabel;
  String rpeLabel;

  List<_SetEntry> sets;
}

class _SetEntry {
  _SetEntry({this.weight, this.reps, this.rpe});

  double? weight;
  int? reps;
  double? rpe;
}