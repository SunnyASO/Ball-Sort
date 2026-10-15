import 'package:ball_sort/game/ball_move.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/board_solver.dart';
import 'package:ball_sort/game/game_controller.dart';
import 'package:ball_sort/game/move_validator.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/levels/level_catalog.dart';
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

    test('GameController addEmptyTube dynamically adds chamber up to 8 tubes', () {
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
    });

    test('Phase A3.1: Level 13 finds true optimal 15-move solution after pruning fix', () {
      final board = LevelCatalog.level13;
      final solution = solver.solve(board);

      expect(solution, isNotNull);
      expect(solution!.length, equals(15), reason: 'Corrected solver must find 15-move optimum');

      // Replay all moves to verify board victory
      var current = board;
      for (final move in solution) {
        final result = current.tryMove(move.sourceTube, move.destinationTube);
        expect(result, isNotNull, reason: 'Every move in solution must be legal');
        current = result!.$1;
      }
      expect(current.isSolved, isTrue);
    });

    test('Phase A3.2: all 20 curated catalog levels are verified solvable and replayed to victory', () {
      for (int i = 1; i <= LevelCatalog.totalLevels; i++) {
        final board = LevelCatalog.getLevel(i);
        final solution = solver.solve(board);

        expect(solution, isNotNull, reason: 'Level $i must be solvable');
        expect(solution!.isNotEmpty, isTrue, reason: 'Level $i must require moves');

        var current = board;
        for (final move in solution) {
          final result = current.tryMove(move.sourceTube, move.destinationTube);
          expect(result, isNotNull, reason: 'Move in Level $i must be legal');
          current = result!.$1;
        }
        expect(current.isSolved, isTrue, reason: 'Replaying Level $i solution must reach victory');
      }
    });

    test('Phase A3.3: multiple source chambers can independently access empty destinations', () {
      // Tube 0: [red, red, red, blue] (top is blue)
      // Tube 1: [blue, blue, blue, red] (top is red)
      // Tube 2: [green, green, green, yellow] (top is yellow)
      // Tube 3: [yellow, yellow, yellow, green] (top is green)
      // Tube 4: []
      // Tube 5: []
      final board = BallSortBoard([
        Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.red, BallType.blue]),
        Tube(capacity: 4, balls: [BallType.blue, BallType.blue, BallType.blue, BallType.red]),
        Tube(capacity: 4, balls: [BallType.green, BallType.green, BallType.green, BallType.yellow]),
        Tube(capacity: 4, balls: [BallType.yellow, BallType.yellow, BallType.yellow, BallType.green]),
        Tube(capacity: 4),
        Tube(capacity: 4),
      ]);

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      expect(solution!.isNotEmpty, isTrue);

      var current = board;
      for (final move in solution) {
        final res = current.tryMove(move.sourceTube, move.destinationTube);
        expect(res, isNotNull);
        current = res!.$1;
      }
      expect(current.isSolved, isTrue);
    });

    test('Phase A3.4: grouped-transfer legality transfers contiguous matching balls atomically', () {
      // Tube 0 has 2 red balls on top: [blue, blue, red, red]
      // Tube 1 has 2 red balls: [red, red]
      // Tube 2 has 2 blue balls: [blue, blue]
      // Tube 3 is empty
      final board = BallSortBoard([
        Tube(capacity: 4, balls: [BallType.blue, BallType.blue, BallType.red, BallType.red]),
        Tube(capacity: 4, balls: [BallType.red, BallType.red]),
        Tube(capacity: 4, balls: [BallType.blue, BallType.blue]),
        Tube(capacity: 4),
      ]);

      final solution = solver.solve(board);
      expect(solution, isNotNull);
      // The first move transfers both red balls atomically from tube 0 to tube 1:
      final firstMove = solution!.first;
      expect(firstMove.sourceTube, equals(0));
      expect(firstMove.destinationTube, equals(1));
      expect(firstMove.ballsMoved, equals(2));
      expect(firstMove.movedBalls, equals([BallType.red, BallType.red]));
    });

    test('Phase A3.5: known unsolvable and already-solved boards return expected results', () {
      // Solved board returns empty list
      final solved = BallSortBoard([
        Tube(capacity: 4, balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue]),
        Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.red, BallType.red]),
        Tube(capacity: 4),
      ]);
      expect(solver.solve(solved), equals([]));

      // Deadlocked board with no legal moves returns null
      final deadlocked = BallSortBoard([
        Tube(capacity: 4, balls: [BallType.red, BallType.blue, BallType.red, BallType.blue]),
        Tube(capacity: 4, balls: [BallType.blue, BallType.red, BallType.blue, BallType.red]),
      ]);
      expect(solver.solve(deadlocked), isNull);
    });

    test('Phase A3.6: solver search is completely deterministic across repeated invocations', () {
      final board = LevelCatalog.getLevel(4);
      final solA = solver.solve(board);
      final solB = solver.solve(board);
      final solC = solver.solve(board);

      expect(solA, isNotNull);
      expect(solB, isNotNull);
      expect(solC, isNotNull);
      expect(solA!.length, equals(solB!.length));
      expect(solA.length, equals(solC!.length));

      for (int i = 0; i < solA.length; i++) {
        expect(solA[i].sourceTube, equals(solB[i].sourceTube));
        expect(solA[i].destinationTube, equals(solB[i].destinationTube));
        expect(solA[i].ballsMoved, equals(solB[i].ballsMoved));
        expect(solA[i].movedBall, equals(solB[i].movedBall));

        expect(solA[i].sourceTube, equals(solC[i].sourceTube));
        expect(solA[i].destinationTube, equals(solC[i].destinationTube));
        expect(solA[i].ballsMoved, equals(solC[i].ballsMoved));
        expect(solA[i].movedBall, equals(solC[i].movedBall));
      }
    });

    test('Phase A3.7: bounded search returns null gracefully when maxStates budget is exceeded', () {
      final complexBoard = LevelCatalog.level11;
      // Budget of only 5 states is insufficient to solve Level 11
      final boundedSolution = solver.solve(complexBoard, maxStates: 5);
      expect(boundedSolution, isNull);
    });

    test('Phase A3.8: shortest-path correctness matches unpruned exhaustive reference BFS on small boards', () {
      // Independent unpruned exhaustive BFS solver that explores ALL legal moves
      // without ANY symmetry or empty-destination pruning
      List<BallMove>? exhaustiveReferenceBfs(BallSortBoard initial) {
        if (initial.isSolved) return [];

        final q = <(BallSortBoard, List<BallMove>)>[(initial, [])];
        final seen = <String>{
          initial.tubes.map((t) => t.balls.map((b) => b.name).join(',')).join(';')
        };

        const v = MoveValidator();
        int head = 0;

        while (head < q.length) {
          final (b, path) = q[head++];
          if (b.isSolved) return path;

          for (int i = 0; i < b.tubeCount; i++) {
            if (b.tubes[i].isEmpty) continue;
            for (int j = 0; j < b.tubeCount; j++) {
              if (i == j) continue;
              if (v.isValidMove(b, i, j)) {
                final res = b.tryMove(i, j, validator: v);
                if (res != null) {
                  final (nextB, m) = res;
                  final key = nextB.tubes.map((t) => t.balls.map((ball) => ball.name).join(',')).join(';');
                  if (seen.add(key)) {
                    if (nextB.isSolved) return [...path, m];
                    q.add((nextB, [...path, m]));
                  }
                }
              }
            }
          }
        }
        return null;
      }

      // Test small test board 1: capacity 3, 2 colors, 3 tubes (2 full, 1 empty)
      final testBoard1 = BallSortBoard([
        Tube(capacity: 3, balls: [BallType.red, BallType.blue, BallType.red]),
        Tube(capacity: 3, balls: [BallType.blue, BallType.red, BallType.blue]),
        Tube(capacity: 3),
      ]);

      final refSolution1 = exhaustiveReferenceBfs(testBoard1);
      final optSolution1 = solver.solve(testBoard1);

      expect(refSolution1, isNotNull);
      expect(optSolution1, isNotNull);
      expect(optSolution1!.length, equals(refSolution1!.length),
          reason: 'BoardSolver length must match exhaustive reference BFS exactly');

      // Test small test board 2: capacity 3, 2 colors, 4 tubes (2 full, 2 empty)
      final testBoard2 = BallSortBoard([
        Tube(capacity: 3, balls: [BallType.blue, BallType.red, BallType.blue]),
        Tube(capacity: 3, balls: [BallType.red, BallType.blue, BallType.red]),
        Tube(capacity: 3),
        Tube(capacity: 3),
      ]);

      final refSolution2 = exhaustiveReferenceBfs(testBoard2);
      final optSolution2 = solver.solve(testBoard2);

      expect(refSolution2, isNotNull);
      expect(optSolution2, isNotNull);
      expect(optSolution2!.length, equals(refSolution2!.length),
          reason: 'BoardSolver length must match exhaustive reference BFS on multi-empty board');
    });
  });
}
