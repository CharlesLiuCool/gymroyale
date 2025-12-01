import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymroyale/widgets/workout_card.dart';
import 'package:gymroyale/models/workout_activity.dart';
import 'package:gymroyale/models/lift_workout.dart';
import 'package:gymroyale/models/cardio_workout.dart';

void main() {
  group('WorkoutCard', () {
    testWidgets('renders lift workout with stats and triggers edit/delete',
        (tester) async {
      // ---- Arrange: lift workout + flags for callbacks ----
      bool editCalled = false;
      bool deleteCalled = false;

      final liftActivity = LiftWorkout(
        // Adjust these named args to match your actual model
        id: 'lift-1',
        title: 'Bench Press',
        startedAt: DateTime.now(),
        weight: 135,
        sets: 3,
        reps: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutCard(
              activity: liftActivity,
              onDelete: () => deleteCalled = true,
              onEdit: () => editCalled = true,
            ),
          ),
        ),
      );

      // ---- Assert: header info ----
      expect(find.text('Bench Press'), findsOneWidget);
      // Date should show "Today • ..." because startedAt is today
      expect(find.textContaining('Today •'), findsOneWidget);

      // ---- Assert: lift stats ----
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Sets'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);

      // We don't depend on exact formatting of the number, just that it has lbs
      expect(find.textContaining('lbs'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      // ---- Act: open popup menu and tap Edit ----
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // ---- Assert: edit called, delete not called ----
      expect(editCalled, isTrue);
      expect(deleteCalled, isFalse);

      // ---- Act: open popup again and tap Delete ----
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // ---- Assert: delete now called ----
      expect(deleteCalled, isTrue);
    });

    testWidgets('renders cardio workout with duration stat',
        (tester) async {
      bool deleteCalled = false;
      bool editCalled = false;

      final cardioActivity = CardioWorkout(
        id: 'cardio-1',
        title: 'Morning Run',
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 45, seconds: 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutCard(
              activity: cardioActivity,
              onDelete: () => deleteCalled = true,
              onEdit: () => editCalled = true,
            ),
          ),
        ),
      );

      // ---- Assert: header ----
      expect(find.text('Morning Run'), findsOneWidget);

      // ---- Assert: cardio stats ----
      expect(find.text('Duration'), findsOneWidget);
      // From _formatDuration: 45m 30s when less than 1h
      expect(find.text('45m 30s'), findsOneWidget);

      // No lift-specific labels
      expect(find.text('Weight'), findsNothing);
      expect(find.text('Sets'), findsNothing);
      expect(find.text('Reps'), findsNothing);

      // ---- Act: delete via popup ----
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
      expect(editCalled, isFalse);
    });

    testWidgets(
        'tapping Edit does nothing when onEdit is null (but still shows menu)',
        (tester) async {
      bool deleteCalled = false;

      final liftActivity = LiftWorkout(
        id: 'lift-2',
        title: 'Squat',
        startedAt: DateTime.now(),
        weight: 185,
        sets: 5,
        reps: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutCard(
              activity: liftActivity,
              onDelete: () => deleteCalled = true,
              onEdit: null, // explicitly null
            ),
          ),
        ),
      );

      // Open menu and tap Edit
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Should not crash and should not trigger delete
      expect(deleteCalled, isFalse);
    });
  });
}