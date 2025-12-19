import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymroyale/services/streak_service.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('updateStreak', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocRef;
    late MockDocumentSnapshot mockDocSnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocRef = MockDocumentReference();
      mockDocSnapshot = MockDocumentSnapshot();

      // Mock the chain firestore.collection('users').doc(userId)
      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
    });

    Future<int> callUpdateStreak({
      int? currentStreak,
      DateTime? lastCheckIn,
      required DateTime now,
    }) async {
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.data()).thenReturn({
        'streakCount': currentStreak,
        'lastCheckIn':
            lastCheckIn != null ? Timestamp.fromDate(lastCheckIn) : null,
      });

      when(() => mockDocRef.update(any())).thenAnswer((_) async => null);

      return updateStreak('user123', firestore: mockFirestore, now: now);
    }

    test('first ever check-in returns streak 1', () async {
      final now = DateTime(2025, 12, 18);
      final streak = await callUpdateStreak(
        currentStreak: null,
        lastCheckIn: null,
        now: now,
      );
      expect(streak, 1);
    });

    test('same day check-in keeps streak', () async {
      final now = DateTime(2025, 12, 18);
      final lastCheckIn = DateTime(2025, 12, 18);
      final streak = await callUpdateStreak(
        currentStreak: 5,
        lastCheckIn: lastCheckIn,
        now: now,
      );
      expect(streak, 5);
    });

    test('yesterday check-in increments streak', () async {
      final now = DateTime(2025, 12, 18);
      final lastCheckIn = DateTime(2025, 12, 17);
      final streak = await callUpdateStreak(
        currentStreak: 3,
        lastCheckIn: lastCheckIn,
        now: now,
      );
      expect(streak, 4);
    });

    test('missed more than 1 day resets streak', () async {
      final now = DateTime(2025, 12, 18);
      final lastCheckIn = DateTime(2025, 12, 15);
      final streak = await callUpdateStreak(
        currentStreak: 7,
        lastCheckIn: lastCheckIn,
        now: now,
      );
      expect(streak, 0);
    });
  });
}
