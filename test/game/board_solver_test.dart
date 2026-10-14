import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/board_solver.dart';
import 'package:ball_sort/game/game_controller.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/levels/prototype_levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoardSolver Unit Tests', () {
    const solver = BoardSolver();

    test('solves Level 1 board and returns valid move sequence', () {
      final board = PrototypeLevels.level1;
      final solution = solver.solve(board);

      expect(solution, isNotNull);
      expect(solution!.isNotEmpty, isTrue);

      // Verify that applying the moves actually solves the board
      var current = board;
      for (final move in solution) {
        final result = current.tryMove(move.sourceTube, move.destinationTube);
        expect(result, isNotNull);
        current = result!.$1;
      }
      expect(current.isSolved, isTrue);
    });

    test('returns empty move list if board is already solved', () {
      final solvedBoard = BallSortBoard([
        Tube(
          capacity: 4,
          balls: [BallType.red, BallType.red, BallType.red, BallType.red],
        ),
        Tube(capacity: 4),
      ]);

      expect(solvedBoard.isSolved, isTrue);
      final solution = solver.solve(solvedBoard);
      expect(solution, equals([]));
    });

    test('returns null for an unsolvable board configuration', () {
      // Both tubes full with mismatched pairs and no empty helper tubes
      final unsolvable = BallSortBoard([
        Tube(
          capacity: 4,
          balls: [BallType.red, BallType.blue, BallType.red, BallType.blue],
        ),
        Tube(
          capacity: 4,
          balls: [BallType.blue, BallType.red, BallType.blue, BallType.red],
        ),
      ]);

      final solution = solver.solve(unsolvable, maxStates: 100);
      expect(solution, isNull);
    });

    test(
      'getNextOptimalMove returns the first move of the optimal solution',
      () {
        final board = PrototypeLevels.level1;
        final nextMove = solver.getNextOptimalMove(board);

        expect(nextMove, isNotNull);
        expect(nextMove!.sourceTube, anyOf(equals(0), equals(1)));
        expect(nextMove.destinationTube, anyOf(equals(2), equals(3)));
      },
    );

    test('canonicalKey treats permutation of empty tubes symmetrically', () {
      final boardA = BallSortBoard([
        Tube(capacity: 4, balls: [BallType.red]),
        Tube(capacity: 4),
        Tube(capacity: 4),
      ]);
      final boardB = BallSortBoard([
        Tube(capacity: 4),
        Tube(capacity: 4, balls: [BallType.red]),
        Tube(capacity: 4),
      ]);

      expect(
        BoardSolver.canonicalKey(boardA),
        equals(BoardSolver.canonicalKey(boardB)),
      );
    });

    test('GameController getHint returns next optimal move and respects lock and solved states', () {
      final controller = GameController(initialBoard: PrototypeLevels.level1);
      final hint = controller.getHint();
      expect(hint, isNotNull);

      // Hint is blocked during input lock
      controller.setInputLocked(true);
      expect(controller.getHint(), isNull);
      controller.setInputLocked(false);

      // Hint is null when solved
      final solvedController = GameController(
        initialBoard: BallSortBoard([
          Tube(
            capacity: 4,
            balls: [BallType.red, BallType.red, BallType.red, BallType.red],
          ),
          Tube(capacity: 4),
        ]),
      );
      expect(solvedController.getHint(), isNull);
    });

    test(
      'GameController addEmptyTube dynamically adds chamber up to 8 tubes',
      () {
        final controller = GameController(initialBoard: PrototypeLevels.level1);
        expect(controller.board.tubeCount, equals(4));

        // Add tubes 5, 6, 7, 8
        expect(controller.addEmptyTube(), isTrue);
        expect(controller.board.tubeCount, equals(5));
        expect(controller.board.tubes.last.isEmpty, isTrue);

        expect(controller.addEmptyTube(), isTrue);
        expect(controller.addEmptyTube(), isTrue);
        expect(controller.addEmptyTube(), isTrue);
        expect(controller.board.tubeCount, equals(8));

        // 9th tube is rejected by capacity cap
        expect(controller.addEmptyTube(), isFalse);
        expect(controller.board.tubeCount, equals(8));
      },
    );
  });
}
