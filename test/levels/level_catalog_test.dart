import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/board_solver.dart';
import 'package:ball_sort/levels/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelCatalog Solvability and Configuration', () {
    const solver = BoardSolver();

    test('exactly 50 curated levels exist and are defined', () {
      expect(LevelCatalog.totalLevels, equals(50));
      expect(() => LevelCatalog.getLevel(0), throwsArgumentError);
      expect(() => LevelCatalog.getLevel(51), throwsArgumentError);

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

    test('all 50 levels respect exact 4-ball capacity and uniform color counts', () {
      for (int i = 1; i <= LevelCatalog.totalLevels; i++) {
        final board = LevelCatalog.getLevel(i);
        final colorCounts = <BallType, int>{};

        var emptyTubes = 0;
        var fullTubes = 0;

        for (final tube in board.tubes) {
          expect(tube.capacity, equals(4), reason: 'Level $i tube capacity');
          if (tube.isEmpty) {
            emptyTubes++;
          } else {
            fullTubes++;
          }
          for (final b in tube.balls) {
            colorCounts[b] = (colorCounts[b] ?? 0) + 1;
          }
        }

        expect(
          emptyTubes,
          inInclusiveRange(1, 3),
          reason: 'Level $i must have between 1 and 3 empty helper tubes',
        );
        expect(
          colorCounts.length,
          equals(fullTubes),
          reason: 'Level $i: color count must equal non-empty tube count',
        );

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

    test('all 50 levels have valid starting moves', () {
      for (int i = 1; i <= LevelCatalog.totalLevels; i++) {
        final board = LevelCatalog.getLevel(i);
        var hasValidMove = false;
        for (int src = 0; src < board.tubeCount; src++) {
          for (int dst = 0; dst < board.tubeCount; dst++) {
            if (src != dst && board.tryMove(src, dst) != null) {
              hasValidMove = true;
              break;
            }
          }
          if (hasValidMove) break;
        }
        expect(hasValidMove, isTrue, reason: 'Level $i must have at least one legal starting move');
      }
    });

    test('solver verifies solvability of all 50 levels across all 10 sectors', () {
      for (int lvl = 1; lvl <= LevelCatalog.totalLevels; lvl++) {
        final board = LevelCatalog.getLevel(lvl);
        final solution = solver.solve(board);
        expect(
          solution,
          isNotNull,
          reason: 'Level $lvl must be proven solvable by BoardSolver',
        );
        expect(solution!.isNotEmpty, isTrue);

        // Verify solution replays to solved state
        var current = board;
        for (final move in solution) {
          final next = current.tryMove(move.sourceTube, move.destinationTube);
          expect(next, isNotNull, reason: 'Level $lvl move $move must be legal');
          current = next!.$1;
        }
        expect(current.isSolved, isTrue, reason: 'Level $lvl replay must reach victory');
      }
    });
  });
}
