import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymroyale/widgets/workout_form.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/models/lift_workout.dart';
import 'package:gymroyale/models/cardio_workout.dart';

void main() {
  // Helper: find a TextFormField by its labelText
  Finder _textFormFieldWithLabel(String label) {
    return find.widgetWithText(TextFormField, label);
  }

  group('WorkoutSheet - edit lift workout', () {
    testWidgets(
      'shows Edit Workout and pre-fills lift fields',
      (tester) async {
        final liftWorkout = LiftWorkout(
          id: 'w1',
          title: 'Bench Press',
          startedAt: DateTime(2024, 1, 1),
          weight: 135.0,
          sets: 3,
          reps: 10,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkoutSheet(
                userId: 'user-1',
                workout: liftWorkout,
                onWorkoutSaved: () {},
              ),
            ),
          ),
        );

        // Let _initValues finish and _loadingDefaults become false
        await tester.pumpAndSettle();

        // Title
        expect(find.text('Edit Workout'), findsOneWidget);

        // Workout name field has the workout title
        final nameFieldFinder = _textFormFieldWithLabel('Workout Name');
        expect(nameFieldFinder, findsOneWidget);
        final nameField =
            tester.widget<TextFormField>(nameFieldFinder);
        expect(nameField.controller?.text, 'Bench Press');

        // Lift fields exist
        final weightFieldFinder = _textFormFieldWithLabel('Weight (lbs)');
        final setsFieldFinder = _textFormFieldWithLabel('Sets');
        final repsFieldFinder = _textFormFieldWithLabel('Reps');

        expect(weightFieldFinder, findsOneWidget);
        expect(setsFieldFinder, findsOneWidget);
        expect(repsFieldFinder, findsOneWidget);

        final weightField =
            tester.widget<TextFormField>(weightFieldFinder);
        final setsField = tester.widget<TextFormField>(setsFieldFinder);
        final repsField = tester.widget<TextFormField>(repsFieldFinder);

        expect(weightField.controller?.text, '135.0');
        expect(setsField.controller?.text, '3');
        expect(repsField.controller?.text, '10');

        // Cardio field should NOT be present
        expect(
          _textFormFieldWithLabel('Duration (minutes)'),
          findsNothing,
        );
      },
    );
  });

  group('WorkoutSheet - edit cardio workout', () {
    testWidgets(
      'shows Edit Workout and pre-fills cardio duration field',
      (tester) async {
        final cardioWorkout = CardioWorkout(
          id: 'c1',
          title: 'Morning Run',
          startedAt: DateTime(2024, 1, 1, 6),
          duration: const Duration(minutes: 45),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkoutSheet(
                userId: 'user-1',
                workout: cardioWorkout,
                onWorkoutSaved: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Title
        expect(find.text('Edit Workout'), findsOneWidget);

        // Name is pre-filled
        final nameFieldFinder = _textFormFieldWithLabel('Workout Name');
        expect(nameFieldFinder, findsOneWidget);
        final nameField =
            tester.widget<TextFormField>(nameFieldFinder);
        expect(nameField.controller?.text, 'Morning Run');

        // Duration field visible and pre-filled with minutes
        final durationFieldFinder =
            _textFormFieldWithLabel('Duration (minutes)');
        expect(durationFieldFinder, findsOneWidget);
        final durationField =
            tester.widget<TextFormField>(durationFieldFinder);
        expect(durationField.controller?.text, '45');

        // Lift fields should NOT be present
        expect(_textFormFieldWithLabel('Weight (lbs)'), findsNothing);
        expect(_textFormFieldWithLabel('Sets'), findsNothing);
        expect(_textFormFieldWithLabel('Reps'), findsNothing);
      },
    );
  });

  group('WorkoutSheet - switching activity type', () {
    testWidgets(
      'switching from lift to cardio shows correct fields',
      (tester) async {
        final liftWorkout = LiftWorkout(
          id: 'w2',
          title: 'Squat',
          startedAt: DateTime(2024, 1, 1),
          weight: 185.0,
          sets: 5,
          reps: 5,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WorkoutSheet(
                userId: 'user-1',
                workout: liftWorkout,
                onWorkoutSaved: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initially lift fields are visible
        expect(_textFormFieldWithLabel('Weight (lbs)'), findsOneWidget);
        expect(_textFormFieldWithLabel('Sets'), findsOneWidget);
        expect(_textFormFieldWithLabel('Reps'), findsOneWidget);
        expect(
          _textFormFieldWithLabel('Duration (minutes)'),
          findsNothing,
        );

        // Open Activity Type dropdown and select "Cardio"
        final dropdownFinder =
            find.byType(DropdownButtonFormField<ActivityType>);
        expect(dropdownFinder, findsOneWidget);

        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        // "Cardio" is the capitalized enum name for ActivityType.cardio
        await tester.tap(find.text('Cardio').last);
        await tester.pumpAndSettle();

        // Now cardio field should be visible
        final durationFieldFinder =
            _textFormFieldWithLabel('Duration (minutes)');
        expect(durationFieldFinder, findsOneWidget);

        final durationField =
            tester.widget<TextFormField>(durationFieldFinder);

        // Your onChanged logic sets a default if empty; just make sure it's non-empty
        expect(durationField.controller?.text.isNotEmpty, isTrue);

        // Lift fields should be gone
        expect(_textFormFieldWithLabel('Weight (lbs)'), findsNothing);
        expect(_textFormFieldWithLabel('Sets'), findsNothing);
        expect(_textFormFieldWithLabel('Reps'), findsNothing);
      },
    );
  });
}