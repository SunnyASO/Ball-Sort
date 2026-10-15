import 'dart:io';

import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/levels/level_catalog.dart';
import 'package:ball_sort/services/progression_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Campaign & Level Integrity Regression Tests', () {
    test('Levels 1-20 board definitions match commit 332b051 byte-for-byte', () {
      // 1. Verify prototype levels 1-6
      final protoResult = Process.runSync('git', [
        'diff',
        '332b051',
        '--',
        'lib/levels/prototype_levels.dart',
      ]);
      expect(protoResult.exitCode, equals(0));
      expect(
        (protoResult.stdout as String).trim(),
        isEmpty,
        reason: 'prototype_levels.dart has unexpected modifications from 332b051',
      );

      // 2. Verify levels 7-20 in level_catalog.dart
      final catResult = Process.runSync('git', [
        'show',
        '332b051:lib/levels/level_catalog.dart',
      ]);
      expect(catResult.exitCode, equals(0));
      final oldCatalogContent = catResult.stdout as String;
      final currentCatalogContent = File(
        'lib/levels/level_catalog.dart',
      ).readAsStringSync();

      for (int lvl = 7; lvl <= 20; lvl++) {
        final getterName = 'static BallSortBoard get level$lvl =>';
        final oldIdx = oldCatalogContent.indexOf(getterName);
        final currentIdx = currentCatalogContent.indexOf(getterName);

        expect(oldIdx, isNot(-1), reason: 'level$lvl must exist in old catalog');
        expect(
          currentIdx,
          isNot(-1),
          reason: 'level$lvl must exist in current catalog',
        );

        final oldEnd = oldCatalogContent.indexOf(']);', oldIdx);
        final currentEnd = currentCatalogContent.indexOf(']);', currentIdx);

        final oldDef = oldCatalogContent.substring(oldIdx, oldEnd + 3);
        final currentDef = currentCatalogContent.substring(
          currentIdx,
          currentEnd + 3,
        );

        expect(
          currentDef,
          equals(oldDef),
          reason: 'Level $lvl was modified compared to commit 332b051!',
        );
      }
    });

    test('Levels 1-50 maintain capacity 4, uniform 4-ball colors, and legal starting moves', () {
      expect(LevelCatalog.totalLevels, equals(50));

      for (int i = 1; i <= 50; i++) {
        final board = LevelCatalog.getLevel(i);
        expect(board.isSolved, isFalse, reason: 'Level $i is already solved');
        expect(board.tubeCount, inInclusiveRange(4, 8));

        final colorCounts = <BallType, int>{};
        var emptyCount = 0;

        for (final tube in board.tubes) {
          expect(tube.capacity, equals(4));
          if (tube.isEmpty) {
            emptyCount++;
          } else {
            for (final ball in tube.balls) {
              colorCounts[ball] = (colorCounts[ball] ?? 0) + 1;
            }
          }
        }

        expect(emptyCount, inInclusiveRange(1, 3));
        for (final entry in colorCounts.entries) {
          expect(
            entry.value,
            equals(4),
            reason: 'Level $i color ${entry.key} count != 4',
          );
        }

        // Verify legal starting move exists
        var hasMove = false;
        for (int src = 0; src < board.tubeCount; src++) {
          for (int dst = 0; dst < board.tubeCount; dst++) {
            if (src != dst && board.tryMove(src, dst) != null) {
              hasMove = true;
              break;
            }
          }
          if (hasMove) break;
        }
        expect(hasMove, isTrue, reason: 'Level $i has no legal starting move');
      }
    });

    test('Level 51 completion sentinel is rejected as a playable level', () {
      expect(() => LevelCatalog.getLevel(0), throwsArgumentError);
      expect(() => LevelCatalog.getLevel(51), throwsArgumentError);
      expect(() => LevelCatalog.getLevel(99), throwsArgumentError);
    });

    test('saved progression compatibility: legacy preferences load and persist correctly', () async {
      // Simulate existing legacy player with levels 1-20 progress
      final mockData = <String, Object>{
        'highestUnlockedLevel': 20,
        'currentLevel': 20,
        'soundEnabled': true,
        'hapticsEnabled': false,
      };
      for (int i = 1; i <= 19; i++) {
        mockData['stars_level_$i'] = 3;
        mockData['best_moves_level_$i'] = 10;
      }

      SharedPreferences.setMockInitialValues(mockData);
      final service = ProgressionService.instance;
      await service.initialize();

      expect(service.highestUnlockedLevel, equals(20));
      expect(service.currentLevel, equals(20));
      expect(service.soundEnabled, isTrue);
      expect(service.hapticsEnabled, isFalse);

      for (int i = 1; i <= 19; i++) {
        expect(service.getStars(i), equals(3));
        expect(service.getBestMoves(i), equals(10));
        expect(service.isLevelUnlocked(i), isTrue);
      }

      // Complete Level 20 -> Unlocks Level 21
      await service.recordLevelCompletion(level: 20, moves: 15, parMoves: 15);
      expect(service.highestUnlockedLevel, equals(21));
      expect(service.isLevelUnlocked(21), isTrue);
      expect(service.isLevelUnlocked(22), isFalse);

      // Complete Level 50 -> Campaign Finished, no Level 51 playable
      await service.recordLevelCompletion(level: 50, moves: 18, parMoves: 18);
      expect(service.getStars(50), equals(3));
      expect(service.getBestMoves(50), equals(18));
      expect(service.highestUnlockedLevel, equals(51)); // Sentinel for 100% complete
    });
  });
}
