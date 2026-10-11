import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/game_controller.dart';
import 'package:ball_sort/game/tube.dart';

void main() {
  group('GameController', () {
    late BallSortBoard initialBoard;

    setUp(() {
      initialBoard = BallSortBoard([
        Tube(balls: [BallType.red, BallType.blue]), // Tube 0
        Tube(balls: [BallType.blue, BallType.red]), // Tube 1
        Tube(), // Tube 2: Empty
      ]);
    });

    test('selection and deselection', () {
      final controller = GameController(initialBoard: initialBoard);

      expect(controller.selectedTubeIndex, isNull);

      // Tapping an empty tube without selection does nothing
      controller.handleTubeTap(2);
      expect(controller.selectedTubeIndex, isNull);

      // Tapping a non-empty tube selects it
      controller.handleTubeTap(0);
      expect(controller.selectedTubeIndex, equals(0));

      // Tapping the selected tube deselects it
      controller.handleTubeTap(0);
      expect(controller.selectedTubeIndex, isNull);
    });

    test('changing selected source when destination move is invalid', () {
      final controller = GameController(initialBoard: initialBoard);

      // Select Tube 0 (top is blue)
      controller.handleTubeTap(0);
      expect(controller.selectedTubeIndex, equals(0));

      // Tap Tube 1 (top is red). Move 0 -> 1 is invalid (blue cannot go on red).
      // Since Tube 1 is non-empty, controller should switch selected source to Tube 1!
      final move = controller.handleTubeTap(1);
      expect(move, isNull);
      expect(controller.selectedTubeIndex, equals(1));
      expect(controller.moveCount, equals(0));
    });

    test(
      'valid move updates board, increments move count, and clears selection',
      () {
        final controller = GameController(initialBoard: initialBoard);

        // Select Tube 0 (top: blue)
        controller.handleTubeTap(0);
        expect(controller.selectedTubeIndex, equals(0));

        // Tap Tube 2 (empty). Valid move!
        final move = controller.handleTubeTap(2);
        expect(move, isNotNull);
        expect(move!.sourceTube, equals(0));
        expect(move.destinationTube, equals(2));
        expect(move.ballsMoved, equals(1));

        expect(controller.selectedTubeIndex, isNull);
        expect(controller.moveCount, equals(1));
        expect(controller.board.tubes[0].balls, equals([BallType.red]));
        expect(controller.board.tubes[2].balls, equals([BallType.blue]));
      },
    );

    test('invalid move behavior does not change board or moveCount', () {
      // Tube 0 (top: blue), Tube 1 (top: red)
      final controller = GameController(initialBoard: initialBoard);
      final originalBoard = controller.board;

      controller.handleTubeTap(0); // Select 0
      final move = controller.handleTubeTap(1); // Invalid destination move

      expect(move, isNull);
      expect(controller.moveCount, equals(0));
      // Tube 0 and Tube 1 balls are completely untouched
      expect(controller.board, equals(originalBoard));
    });

    test('input locking behavior ignores taps', () {
      final controller = GameController(initialBoard: initialBoard);
      controller.setInputLocked(true);
      expect(controller.inputLocked, isTrue);

      final move = controller.handleTubeTap(0);
      expect(move, isNull);
      expect(controller.selectedTubeIndex, isNull);

      // Unlock and verify interaction works
      controller.setInputLocked(false);
      controller.handleTubeTap(0);
      expect(controller.selectedTubeIndex, equals(0));

      // Lock again while selected
      controller.setInputLocked(true);
      final moveWhileLocked = controller.handleTubeTap(2);
      expect(moveWhileLocked, isNull);
      expect(controller.moveCount, equals(0));
    });

    test('solved state behavior rejects further forward moves', () {
      // Create a near-solved board where one move wins
      final nearSolvedBoard = BallSortBoard([
        Tube(
          balls: [BallType.red, BallType.red, BallType.red],
        ), // 0: needs 1 red
        Tube(balls: [BallType.red]), // 1: top is red
        Tube(
          balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
        ), // 2: complete
      ]);

      final controller = GameController(initialBoard: nearSolvedBoard);
      expect(controller.solved, isFalse);

      // Move red from 1 to 0
      controller.handleTubeTap(1);
      final winMove = controller.handleTubeTap(0);

      expect(winMove, isNotNull);
      expect(controller.solved, isTrue);
      expect(controller.moveCount, equals(1));

      // Subsequent taps must be ignored
      final tapAfterWin = controller.handleTubeTap(0);
      expect(tapAfterWin, isNull);
      expect(controller.selectedTubeIndex, isNull);
    });

    test('restart restores exact original state and unlocks input', () {
      final controller = GameController(initialBoard: initialBoard);

      // Make a move
      controller.handleTubeTap(0);
      controller.handleTubeTap(2);
      expect(controller.moveCount, equals(1));
      expect(controller.board, isNot(equals(initialBoard)));

      controller.setInputLocked(true);

      // Restart
      controller.restart();

      expect(controller.board, equals(initialBoard));
      expect(controller.selectedTubeIndex, isNull);
      expect(controller.moveCount, equals(0));
      expect(controller.inputLocked, isFalse);
      expect(controller.solved, isFalse);
    });

    test('rapid sequential operations do not cause unexpected mutation', () {
      final controller = GameController(initialBoard: initialBoard);

      // Sequence: select 0 -> deselect 0 -> select 1 -> switch to 0 -> move to 2
      controller.handleTubeTap(0); // select 0
      controller.handleTubeTap(0); // deselect
      expect(controller.selectedTubeIndex, isNull);

      controller.handleTubeTap(1); // select 1
      controller.handleTubeTap(0); // switch to 0 (top blue != top red)
      expect(controller.selectedTubeIndex, equals(0));

      final move = controller.handleTubeTap(2); // move to 2 (empty)
      expect(move, isNotNull);
      expect(controller.moveCount, equals(1));
      expect(controller.board.tubes[0].balls, equals([BallType.red]));
      expect(controller.board.tubes[2].balls, equals([BallType.blue]));

      // Now Tube 0 top is red, Tube 1 top is red. Move 0 -> 1 should succeed!
      controller.handleTubeTap(0); // select 0
      final move2 = controller.handleTubeTap(1); // move 0 -> 1
      expect(move2, isNotNull);
      expect(controller.moveCount, equals(2));
      expect(controller.board.tubes[0].isEmpty, isTrue);
      expect(
        controller.board.tubes[1].balls,
        equals([BallType.blue, BallType.red, BallType.red]),
      );
    });

    test('out of bounds tube indices are rejected safely', () {
      final controller = GameController(initialBoard: initialBoard);

      expect(controller.handleTubeTap(-1), isNull);
      expect(controller.handleTubeTap(99), isNull);
      expect(controller.selectedTubeIndex, isNull);

      controller.handleTubeTap(0); // select 0
      expect(controller.handleTubeTap(-1), isNull);
      // Selection should remain 0
      expect(controller.selectedTubeIndex, equals(0));
    });

    group('Undo Functionality', () {
      test(
        'undo restores original source and destination and exact ball ordering',
        () {
          final controller = GameController(initialBoard: initialBoard);

          // Move 0 -> 2 (blue to empty tube 2)
          controller.handleTubeTap(0);
          final move = controller.handleTubeTap(2);
          expect(move, isNotNull);
          expect(controller.board.tubes[0].balls, equals([BallType.red]));
          expect(controller.board.tubes[2].balls, equals([BallType.blue]));
          expect(controller.moveCount, equals(1));
          expect(controller.canUndo, isTrue);

          // Undo
          final undoneMove = controller.undo();
          expect(undoneMove, isNotNull);
          expect(undoneMove!.sourceTube, equals(0));
          expect(undoneMove.destinationTube, equals(2));

          // Exact original configuration restored
          expect(controller.board, equals(initialBoard));
          expect(
            controller.board.tubes[0].balls,
            equals([BallType.red, BallType.blue]),
          );
          expect(controller.board.tubes[2].isEmpty, isTrue);
          expect(controller.moveCount, equals(0));
          expect(controller.canUndo, isFalse);
        },
      );

      test('undo with empty history does nothing', () {
        final controller = GameController(initialBoard: initialBoard);
        expect(controller.canUndo, isFalse);
        final undone = controller.undo();
        expect(undone, isNull);
        expect(controller.board, equals(initialBoard));
        expect(controller.moveCount, equals(0));
      });

      test('undo after multiple moves reverses in LIFO order', () {
        final controller = GameController(initialBoard: initialBoard);

        // Move 1: 0 -> 2
        controller.handleTubeTap(0);
        controller.handleTubeTap(2);

        // Move 2: 1 -> 2 (since 1 top is red and 2 top is blue, invalid -> switches to 1)
        // Let's do a valid move 2: 0 top is red, 1 top is red -> 0 -> 1
        controller.handleTubeTap(0);
        controller.handleTubeTap(1);

        expect(controller.moveCount, equals(2));
        expect(controller.moveHistory.length, equals(2));

        // Undo move 2 (0 -> 1)
        final undone2 = controller.undo();
        expect(undone2!.sourceTube, equals(0));
        expect(undone2.destinationTube, equals(1));
        expect(controller.moveCount, equals(1));
        expect(controller.moveHistory.length, equals(1));

        // Undo move 1 (0 -> 2)
        final undone1 = controller.undo();
        expect(undone1!.sourceTube, equals(0));
        expect(undone1.destinationTube, equals(2));
        expect(controller.moveCount, equals(0));
        expect(controller.moveHistory.isEmpty, isTrue);

        // Exactly back to start
        expect(controller.board, equals(initialBoard));
      });

      test('invalid taps do not affect undo history', () {
        final controller = GameController(initialBoard: initialBoard);

        // Invalid move tap
        controller.handleTubeTap(0); // select 0
        controller.handleTubeTap(1); // invalid move (switch to 1)
        expect(controller.moveHistory, isEmpty);
        expect(controller.canUndo, isFalse);

        final undone = controller.undo();
        expect(undone, isNull);
      });

      test('restart clears undo history', () {
        final controller = GameController(initialBoard: initialBoard);
        controller.handleTubeTap(0);
        controller.handleTubeTap(2);
        expect(controller.canUndo, isTrue);

        controller.restart();
        expect(controller.canUndo, isFalse);
        expect(controller.moveHistory, isEmpty);
        expect(controller.undo(), isNull);
      });

      test('undo is blocked during input lock', () {
        final controller = GameController(initialBoard: initialBoard);
        controller.handleTubeTap(0);
        controller.handleTubeTap(2);
        expect(controller.canUndo, isTrue);

        controller.setInputLocked(true);
        expect(controller.canUndo, isFalse);
        final undone = controller.undo();
        expect(undone, isNull);
        expect(controller.moveCount, equals(1));

        controller.setInputLocked(false);
        expect(controller.canUndo, isTrue);
        expect(controller.undo(), isNotNull);
        expect(controller.moveCount, equals(0));
      });

      test('undo clears current selection', () {
        final controller = GameController(initialBoard: initialBoard);
        controller.handleTubeTap(0);
        controller.handleTubeTap(2); // move done, selection null

        controller.handleTubeTap(1); // select tube 1
        expect(controller.selectedTubeIndex, equals(1));

        controller.undo();
        expect(controller.selectedTubeIndex, isNull);
      });

      test('undo after winning correctly restores previous unsolved state', () {
        final nearSolvedBoard = BallSortBoard([
          Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.red]),
          Tube(capacity: 4, balls: [BallType.red]),
          Tube(
            capacity: 4,
            balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
          ),
        ]);

        final controller = GameController(initialBoard: nearSolvedBoard);
        controller.handleTubeTap(1);
        final winMove = controller.handleTubeTap(0);
        expect(winMove, isNotNull);
        expect(controller.solved, isTrue);
        expect(controller.moveCount, equals(1));

        // Undo the winning move
        final undone = controller.undo();
        expect(undone, isNotNull);
        expect(controller.solved, isFalse);
        expect(controller.moveCount, equals(0));
        expect(controller.board, equals(nearSolvedBoard));
      });

      test('grouped multi-ball transfer undo restores exact tube state in a single step', () {
        // Tube 0: [Red, Blue, Blue, Blue]
        // Tube 1: Empty
        final board = BallSortBoard([
          Tube(
            balls: [BallType.red, BallType.blue, BallType.blue, BallType.blue],
          ),
          Tube(),
        ]);

        final controller = GameController(initialBoard: board);

        // Move 3 blue balls: 0 -> 1
        controller.handleTubeTap(0);
        final move = controller.handleTubeTap(1);
        expect(move, isNotNull);
        expect(move!.ballsMoved, equals(3));
        expect(controller.moveCount, equals(1));
        expect(controller.board.tubes[0].balls, equals([BallType.red]));
        expect(
          controller.board.tubes[1].balls,
          equals([BallType.blue, BallType.blue, BallType.blue]),
        );

        // Single undo operation reverses entire 3-ball group
        final undone = controller.undo();
        expect(undone, isNotNull);
        expect(undone!.ballsMoved, equals(3));
        expect(controller.moveCount, equals(0));
        expect(
          controller.board.tubes[0].balls,
          equals([BallType.red, BallType.blue, BallType.blue, BallType.blue]),
        );
        expect(controller.board.tubes[1].isEmpty, isTrue);
        expect(controller.board, equals(board));
      });

      test('grouped winning move undo restores previous configuration and unsolved status', () {
        // Tube 0: 2 red balls. Tube 1: 2 red balls. Tube 2: 4 blue balls (complete).
        final board = BallSortBoard([
          Tube(balls: [BallType.red, BallType.red]),
          Tube(balls: [BallType.red, BallType.red]),
          Tube(
            balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
          ),
        ]);

        final controller = GameController(initialBoard: board);

        // Move 2 red balls from 1 -> 0
        controller.handleTubeTap(1);
        final move = controller.handleTubeTap(0);
        expect(move, isNotNull);
        expect(move!.ballsMoved, equals(2));
        expect(controller.solved, isTrue);
        expect(controller.moveCount, equals(1));

        // Undo
        final undone = controller.undo();
        expect(undone, isNotNull);
        expect(undone!.ballsMoved, equals(2));
        expect(controller.solved, isFalse);
        expect(controller.moveCount, equals(0));
        expect(controller.board, equals(board));
      });
    });
  });
}
