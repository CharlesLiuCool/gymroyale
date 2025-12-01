import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:gymroyale/widgets/gym_checkin_button.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/theme/app_colors.dart';

class MockLeaderboardRepository extends Mock implements LeaderboardRepository {}

void main() {
  late MockLeaderboardRepository mockRepo;

  setUp(() {
    mockRepo = MockLeaderboardRepository();
  });

  Widget _buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: GymCheckInButton(
          userId: 'test-user',
          repo: mockRepo,
        ),
      ),
    );
  }

  group('GymCheckInButton UI', () {
    testWidgets('renders inside SafeArea with padding and button',
        (tester) async {
      await tester.pumpWidget(_buildTestableWidget());

      // SafeArea wrapper
      expect(find.byType(SafeArea), findsOneWidget);

      // Padding wrapper
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding,
          const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0));

      // ElevatedButton exists
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows "Check In at Gym" text by default', (tester) async {
      await tester.pumpWidget(_buildTestableWidget());

      expect(find.text('Check In at Gym'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('button is enabled by default with correct style',
        (tester) async {
      await tester.pumpWidget(_buildTestableWidget());

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<ElevatedButton>(buttonFinder);

      // onPressed should not be null initially (i.e., enabled)
      expect(button.onPressed, isNotNull);

      // Style checks
      final style = button.style;
      // backgroundColor is a MaterialStateProperty, resolve it for default state
      final bgColor = style?.backgroundColor?.resolve(<MaterialState>{});
      final fgColor = style?.foregroundColor?.resolve(<MaterialState>{});

      expect(bgColor, AppColors.accent);
      expect(fgColor, AppColors.textPrimary);
    });
  });
}