import 'package:ball_sort/game/ball_move.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/levels/level_catalog.dart';
import 'package:ball_sort/services/hint_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HintService & SolverResult Tests', () {
    final hintService = HintService.instance;

    test('already solved board returns immediate empty solution', () async {
      final solvedBoard = BallSortBoard([
        Tube(
          capacity: 4,
          balls: [BallType.red, BallType.red, BallType.red, BallType.red],
        ),
        Tube(
          capacity: 4,
          balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
        ),
        Tube(capacity: 4),
      ]);

      final result = await hintService.requestHint(board: solvedBoard);
      expect(result.isSolved, isTrue);
      expect(result.solution, isEmpty);
      expect(result.exceededBudget, isFalse);
    });

    test('easy level (Level 1) resolves fast within fastThreshold', () async {
      final board1 = LevelCatalog.getLevel(1);
      final result = await hintService.requestHint(
        board: board1,
        fastThreshold: 150,
      );

      expect(result.isSolved, isTrue);
      expect(result.solution, isNotNull);
      expect(result.solution!.first, isA<BallMove>());
      expect(result.exceededBudget, isFalse);
      expect(result.statesExplored, lessThanOrEqualTo(150));
    });

    test('complex level (Level 14) offloads to worker isolate and returns optimal hint', () async {
      final board14 = LevelCatalog.getLevel(14);
      final result = await hintService.requestHint(
        board: board14,
        fastThreshold: 50, // Force background isolate offloading
        maxStates: 30000,
      );

      expect(result.isSolved, isTrue);
      expect(result.solution, isNotNull);
      expect(result.solution!.length, equals(16));
      expect(result.solution!.first.sourceTube, inInclusiveRange(0, 7));
      expect(result.exceededBudget, isFalse);
    });

    test('solver budget cutoff is treated as indeterminate rather than unsolvable', () async {
      final board14 = LevelCatalog.getLevel(14);
      final result = await hintService.requestHint(
        board: board14,
        fastThreshold: 20,
        maxStates: 50, // Intentionally restrict budget
      );

      expect(result.isSolved, isFalse);
      expect(result.exceededBudget, isTrue);
      expect(result.isUnsolvable, isFalse);
    });

    test('definitively unsolvable board is detected when search space is exhausted', () async {
      // Create a deadlocked board with no empty tubes and mismatching top balls
      final unsolvableBoard = BallSortBoard([
        Tube(
          capacity: 4,
          balls: [BallType.red, BallType.blue, BallType.red, BallType.blue],
        ),
        Tube(
          capacity: 4,
          balls: [BallType.blue, BallType.red, BallType.blue, BallType.red],
        ),
      ]);

      final result = await hintService.requestHint(
        board: unsolvableBoard,
        fastThreshold: 100,
        maxStates: 1000,
      );

      expect(result.isSolved, isFalse);
      expect(result.exceededBudget, isFalse);
      expect(result.isUnsolvable, isTrue);
    });
  });
}
