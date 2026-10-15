import 'package:ball_sort/services/progression_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProgressionService Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ProgressionService.instance.initialize();
      await ProgressionService.instance.resetAll();
    });

    test('initial state defaults to Level 1 unlocked with sound and haptics enabled', () {
      final service = ProgressionService.instance;
      expect(service.highestUnlockedLevel, equals(1));
      expect(service.currentLevel, equals(1));
      expect(service.soundEnabled, isTrue);
      expect(service.hapticsEnabled, isTrue);
      expect(service.isLevelUnlocked(1), isTrue);
      expect(service.isLevelUnlocked(2), isFalse);
      expect(service.getStars(1), equals(0));
      expect(service.getBestMoves(1), isNull);
    });

    test(
      'recordLevelCompletion unlocks next level and saves stars and best moves',
      () async {
        final service = ProgressionService.instance;

        // Complete Level 1 in 7 moves (par is 10) -> 3 stars
        final starsEarned = await service.recordLevelCompletion(
          level: 1,
          moves: 7,
          parMoves: 10,
        );

        expect(starsEarned, equals(3));
        expect(service.getStars(1), equals(3));
        expect(service.getBestMoves(1), equals(7));
        expect(service.highestUnlockedLevel, equals(2));
        expect(service.isLevelUnlocked(2), isTrue);
        expect(service.isLevelUnlocked(3), isFalse);
      },
    );

    test(
      'replaying a level only updates best moves if move count improves',
      () async {
        final service = ProgressionService.instance;

        await service.recordLevelCompletion(level: 1, moves: 10);
        expect(service.getBestMoves(1), equals(10));

        // Slower replay (14 moves) should NOT overwrite best move count
        await service.recordLevelCompletion(level: 1, moves: 14);
        expect(service.getBestMoves(1), equals(10));

        // Faster replay (8 moves) SHOULD overwrite best move count
        await service.recordLevelCompletion(level: 1, moves: 8);
        expect(service.getBestMoves(1), equals(8));
      },
    );

    test('setting toggles persist audio and haptic preferences', () async {
      final service = ProgressionService.instance;

      await service.setSoundEnabled(false);
      expect(service.soundEnabled, isFalse);

      await service.setHapticsEnabled(false);
      expect(service.hapticsEnabled, isFalse);

      await service.setCurrentLevel(4);
      expect(service.currentLevel, equals(4));
    });

    test('Level 20 completion unlocks Level 21 seamlessly', () async {
      final service = ProgressionService.instance;

      // Simulate player reaching Level 20
      await service.recordLevelCompletion(level: 19, moves: 12);
      expect(service.highestUnlockedLevel, equals(20));
      expect(service.isLevelUnlocked(20), isTrue);
      expect(service.isLevelUnlocked(21), isFalse);

      // Complete Level 20
      final stars = await service.recordLevelCompletion(
        level: 20,
        moves: 15,
        parMoves: 15,
      );

      expect(stars, equals(3));
      expect(service.highestUnlockedLevel, equals(21));
      expect(service.isLevelUnlocked(21), isTrue);
      expect(service.isLevelUnlocked(22), isFalse);
    });

    test('Level 50 completion completes campaign cleanly', () async {
      final service = ProgressionService.instance;

      // Simulate player completing Level 50
      final stars = await service.recordLevelCompletion(
        level: 50,
        moves: 18,
        parMoves: 18,
      );

      expect(stars, equals(3));
      expect(service.getStars(50), equals(3));
      expect(service.getBestMoves(50), equals(18));
      expect(service.isLevelUnlocked(50), isTrue);
    });

    test('star ratings and best moves persist across all 50 levels on reinitialization', () async {
      final service = ProgressionService.instance;

      for (int i = 1; i <= 50; i++) {
        await service.recordLevelCompletion(level: i, moves: 10 + (i % 5));
      }

      // Re-initialize from the underlying mock storage
      await service.initialize();

      for (int i = 1; i <= 50; i++) {
        expect(
          service.getStars(i),
          greaterThan(0),
          reason: 'Level $i stars must be preserved across reload',
        );
        expect(
          service.getBestMoves(i),
          equals(10 + (i % 5)),
          reason: 'Level $i best moves must be preserved across reload',
        );
        expect(service.isLevelUnlocked(i), isTrue);
      }
    });
  });
}
