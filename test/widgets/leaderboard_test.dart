import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymroyale/widgets/leaderboard.dart';
import 'package:gymroyale/widgets/leaderboard_row.dart';
import 'package:gymroyale/models/user.dart';

/// Simple fake repo that matches the `repo.topUsers({int limit})` contract.
class FakeLeaderboardRepo {
  final Stream<List<User>> _stream;
  FakeLeaderboardRepo(this._stream);

  Stream<List<User>> topUsers({int limit = 20}) => _stream;
}

void main() {
  group('Leaderboard', () {
    testWidgets('shows loading indicator while waiting for stream',
        (tester) async {
      final controller = StreamController<List<User>>();
      final repo = FakeLeaderboardRepo(controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Leaderboard(repo: repo),
          ),
        ),
      );

      // While no data has been emitted, connectionState == waiting
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets('shows "No users yet" when stream emits empty list',
        (tester) async {
      final repo = FakeLeaderboardRepo(Stream.value(<User>[]));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Leaderboard(repo: repo),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No users yet'), findsOneWidget);
    });

    testWidgets('renders rows for < 4 users and no toggle button',
        (tester) async {
      // Adjust User constructor to match your actual model
      final users = <User>[
        User(id: 'u1', name: 'Alice', points: 100),
        User(id: 'u2', name: 'Bob', points: 80),
        User(id: 'u3', name: 'Charlie', points: 60),
      ];

      final repo = FakeLeaderboardRepo(Stream.value(users));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Leaderboard(repo: repo),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Some rows rendered (all 3 fit in the height so this is fine)
      expect(find.byType(LeaderboardRow), findsNWidgets(3));

      // No "Show More" / "Show Less" button because users.length < 4
      expect(find.text('Show More'), findsNothing);
      expect(find.text('Show Less'), findsNothing);
    });

    testWidgets(
        'renders rows for >= 4 users with toggle button that expands/collapses',
        (tester) async {
      // 5 users → toggle button should appear
      final users = <User>[
        User(id: 'u1', name: 'Alice', points: 100),
        User(id: 'u2', name: 'Bob', points: 90),
        User(id: 'u3', name: 'Charlie', points: 80),
        User(id: 'u4', name: 'Diana', points: 70),
        User(id: 'u5', name: 'Eve', points: 60),
      ];

      final repo = FakeLeaderboardRepo(Stream.value(users));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Leaderboard(
              repo: repo,
              initialHeight: 180,
              expandedHeight: 400,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ListView exists and has itemCount = 5
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      final listView = tester.widget<ListView>(listViewFinder);
      final delegate = listView.childrenDelegate;
      expect(delegate, isA<SliverChildBuilderDelegate>());
      final builderDelegate = delegate as SliverChildBuilderDelegate;
      expect(builderDelegate.estimatedChildCount, 5);

      // We will see only as many rows as fit into the initial height (likely 3),
      // so just assert that at least one LeaderboardRow exists.
      expect(find.byType(LeaderboardRow), findsWidgets);

      // Toggle button visible, initial text "Show More" + arrow down
      expect(find.text('Show More'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.text('Show Less'), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);

      // AnimatedContainer that WRAPS the ListView
      final animatedContainerFinder = find.ancestor(
        of: listViewFinder,
        matching: find.byType(AnimatedContainer),
      );
      expect(animatedContainerFinder, findsOneWidget);

      final initialSize = tester.getSize(animatedContainerFinder);
      expect(initialSize.height, 180);

      // ListView is not scrollable when collapsed
      var listViewCollapsed =
          tester.widget<ListView>(listViewFinder);
      expect(listViewCollapsed.physics,
          isA<NeverScrollableScrollPhysics>());

      // Tap "Show More" to expand
      await tester.tap(find.text('Show More'));
      await tester.pumpAndSettle();

      // Toggle text & icon switched
      expect(find.text('Show Less'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
      expect(find.text('Show More'), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

      // Container height should now be expandedHeight (or min(calc, expandedHeight))
      final expandedSize = tester.getSize(animatedContainerFinder);
      expect(expandedSize.height, 300);

      // ListView is scrollable when expanded
      var listViewExpanded =
          tester.widget<ListView>(listViewFinder);
      expect(listViewExpanded.physics,
          isA<AlwaysScrollableScrollPhysics>());

      // Optional: scroll and check that the last user ("Eve") can be found
      await tester.drag(listViewFinder, const Offset(0, -300));
      await tester.pump();

      expect(find.text('Eve'), findsOneWidget);
    });
  });
}
