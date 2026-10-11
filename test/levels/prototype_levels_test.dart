import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/levels/prototype_levels.dart';

import '../helpers/level_solver_helper.dart';

void main() {
  group('PrototypeLevels Solvability and Configuration', () {
    final solver = LevelSolverHelper();

    test('exactly six levels exist and are defined', () {
      expect(PrototypeLevels.totalLevels, equals(6));
      expect(() => PrototypeLevels.getLevel(0), throwsArgumentError);
      expect(() => PrototypeLevels.getLevel(7), throwsArgumentError);

      for (int i = 1; i <= 6; i++) {
        final board = PrototypeLevels.getLevel(i);
        expect(board, isNotNull);
        expect(
          board.isSolved,
          isFalse,
          reason: 'Level $i should not start solved',
        );
      }
    });

    test('level 1 specifications and verified solution', () {
      final board = PrototypeLevels.level1;
      expect(board.tubeCount, equals(4));
      expect(board.totalBallCount, equals(8));

      // Verify colors: 4 red, 4 blue
      final colorCounts = <BallType, int>{};
      for (final tube in board.tubes) {
        expect(tube.capacity, equals(4));
        for (final b in tube.balls) {
          colorCounts[b] = (colorCounts[b] ?? 0) + 1;
        }
      }
      expect(colorCounts[BallType.red], equals(4));
      expect(colorCounts[BallType.blue], equals(4));

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      // Grouped movement reduces shortest solution from 8 to 7 moves
      expect(solution!.length, equals(7));
    });

    test('level 2 specifications and verified solution', () {
      final board = PrototypeLevels.level2;
      expect(board.tubeCount, equals(5));
      expect(board.totalBallCount, equals(12));

      // 3 colors: 4 red, 4 blue, 4 green
      final colorCounts = <BallType, int>{};
      for (final tube in board.tubes) {
        expect(tube.capacity, equals(4));
        for (final b in tube.balls) {
          colorCounts[b] = (colorCounts[b] ?? 0) + 1;
        }
      }
      expect(colorCounts[BallType.red], equals(4));
      expect(colorCounts[BallType.blue], equals(4));
      expect(colorCounts[BallType.green], equals(4));

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      // Grouped movement reduces shortest solution from 11 to 9 moves
      expect(solution!.length, equals(9));
    });

    test('level 3 specifications and verified solution', () {
      final board = PrototypeLevels.level3;
      expect(board.tubeCount, equals(5));
      expect(board.totalBallCount, equals(12));

      final colorCounts = <BallType, int>{};
      for (final tube in board.tubes) {
        expect(tube.capacity, equals(4));
        for (final b in tube.balls) {
          colorCounts[b] = (colorCounts[b] ?? 0) + 1;
        }
      }
      expect(colorCounts[BallType.red], equals(4));
      expect(colorCounts[BallType.blue], equals(4));
      expect(colorCounts[BallType.green], equals(4));

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      // Grouped movement reduces shortest solution from 11 to 9 moves
      expect(solution!.length, equals(9));
    });

    test('level 4 specifications and verified solution', () {
      final board = PrototypeLevels.level4;
      expect(board.tubeCount, equals(6));
      expect(board.totalBallCount, equals(16));

      // 4 colors: red, blue, green, yellow
      final colorCounts = <BallType, int>{};
      for (final tube in board.tubes) {
        expect(tube.capacity, equals(4));
        for (final b in tube.balls) {
          colorCounts[b] = (colorCounts[b] ?? 0) + 1;
        }
      }
      expect(colorCounts[BallType.red], equals(4));
      expect(colorCounts[BallType.blue], equals(4));
      expect(colorCounts[BallType.green], equals(4));
      expect(colorCounts[BallType.yellow], equals(4));

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      // Grouped movement reduces shortest solution from 15 to 13 moves
      expect(solution!.length, equals(13));
    });

    test('level 5 specifications and verified solution', () {
      final board = PrototypeLevels.level5;
      expect(board.tubeCount, equals(7));
      expect(board.totalBallCount, equals(20));

      // 5 colors: red, blue, green, yellow, purple
      final colorCounts = <BallType, int>{};
      for (final tube in board.tubes) {
        expect(tube.capacity, equals(4));
        for (final b in tube.balls) {
          colorCounts[b] = (colorCounts[b] ?? 0) + 1;
        }
      }
      expect(colorCounts[BallType.red], equals(4));
      expect(colorCounts[BallType.blue], equals(4));
      expect(colorCounts[BallType.green], equals(4));
      expect(colorCounts[BallType.yellow], equals(4));
      expect(colorCounts[BallType.purple], equals(4));

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      // Grouped movement reduces shortest solution from 18 to 15 moves
      expect(solution!.length, equals(15));
    });

    test('level 6 specifications and verified solution', () {
      final board = PrototypeLevels.level6;
      expect(board.tubeCount, equals(7));
      expect(board.totalBallCount, equals(20));

      final colorCounts = <BallType, int>{};
      for (final tube in board.tubes) {
        expect(tube.capacity, equals(4));
        for (final b in tube.balls) {
          colorCounts[b] = (colorCounts[b] ?? 0) + 1;
        }
      }
      expect(colorCounts[BallType.red], equals(4));
      expect(colorCounts[BallType.blue], equals(4));
      expect(colorCounts[BallType.green], equals(4));
      expect(colorCounts[BallType.yellow], equals(4));
      expect(colorCounts[BallType.purple], equals(4));

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      // Grouped movement reduces shortest solution from 19 to 16 moves
      expect(solution!.length, equals(16));
    });
  });
}
