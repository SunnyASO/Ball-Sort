import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/board_solver.dart';
import 'package:ball_sort/levels/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelCatalog Solvability and Configuration', () {
    const solver = BoardSolver();

    test('exactly 20 curated levels exist and are defined', () {
      expect(LevelCatalog.totalLevels, equals(20));
      expect(() => LevelCatalog.getLevel(0), throwsArgumentError);
      expect(() => LevelCatalog.getLevel(21), throwsArgumentError);

      for (int i = 1; i <= LevelCatalog.totalLevels; i++) {
        final board = LevelCatalog.getLevel(i);
        expect(board, isNotNull);
        expect(
          board.isSolved,
          isFalse,
          reason: 'Level $i should not start already solved',
        );
        expect(board.tubeCount, inInclusiveRange(4, 8));
      }
    });

    test('all 20 levels respect exact 4-ball capacity and uniform color counts', () {
      for (int i = 1; i <= LevelCatalog.totalLevels; i++) {
        final board = LevelCatalog.getLevel(i);
        final colorCounts = <BallType, int>{};

        for (final tube in board.tubes) {
          expect(tube.capacity, equals(4), reason: 'Level $i tube capacity');
          for (final b in tube.balls) {
            colorCounts[b] = (colorCounts[b] ?? 0) + 1;
          }
        }

        for (final entry in colorCounts.entries) {
          expect(
            entry.value,
            equals(4),
            reason:
                'Level $i: color ${entry.key} must have exactly 4 balls across all tubes',
          );
        }
      }
    });

    test('solver verifies solvability of sample sector levels', () {
      // Test sample levels from each sector
      for (final lvl in [1, 5, 7, 10, 14, 20]) {
        final board = LevelCatalog.getLevel(lvl);
        final solution = solver.solve(board);
        expect(
          solution,
          isNotNull,
          reason: 'Level $lvl must be proven solvable by BoardSolver',
        );
        expect(solution!.isNotEmpty, isTrue);
      }
    });
  });
}
