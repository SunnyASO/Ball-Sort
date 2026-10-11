import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/tube.dart';

void main() {
  group('BallSortBoard Transitions', () {
    test('exactly one ball moves and updates source/dest correctly', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red, BallType.blue]), // 0
        Tube(balls: [BallType.green]), // 1
        Tube(), // 2
      ]);

      final initialBallCount = board.totalBallCount;
      final moveResult = board.tryMove(0, 2);

      expect(moveResult, isNotNull);
      final (updatedBoard, move) = moveResult!;

      expect(move.sourceTube, equals(0));
      expect(move.destinationTube, equals(2));
      expect(move.ballsMoved, equals(1));

      // Source should have lost blue ball
      expect(updatedBoard.tubes[0].balls, equals([BallType.red]));
      // Destination should now have blue ball
      expect(updatedBoard.tubes[2].balls, equals([BallType.blue]));
      // Unrelated tube should be unchanged
      expect(updatedBoard.tubes[1].balls, equals([BallType.green]));

      // Total ball count preserved
      expect(updatedBoard.totalBallCount, equals(initialBallCount));
    });

    test('invalid moves leave state unchanged and return null', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red, BallType.blue]), // 0: top blue
        Tube(balls: [BallType.green, BallType.yellow]), // 1: top yellow
      ]);

      final moveResult = board.tryMove(0, 1);
      expect(moveResult, isNull);
      expect(board.tubes[0].balls, equals([BallType.red, BallType.blue]));
      expect(board.tubes[1].balls, equals([BallType.green, BallType.yellow]));
    });

    test('original board remains unchanged (immutability)', () {
      final tube0 = Tube(balls: [BallType.red, BallType.blue]);
      final tube1 = Tube();
      final board = BallSortBoard([tube0, tube1]);

      final moveResult = board.tryMove(0, 1);
      expect(moveResult, isNotNull);

      // Verify original board instance is unmodified
      expect(board.tubes[0].balls, equals([BallType.red, BallType.blue]));
      expect(board.tubes[1].isEmpty, isTrue);
    });

    test('external mutation does not affect internal tubes list', () {
      final list = [
        Tube(balls: [BallType.red]),
        Tube(),
      ];
      final board = BallSortBoard(list);

      list.add(Tube());
      expect(board.tubes.length, equals(2));
      expect(() => board.tubes.add(Tube()), throwsUnsupportedError);
    });

    test('solved board detected correctly', () {
      // Solved: one tube full red, one tube full blue, one empty
      final solvedBoard = BallSortBoard([
        Tube(balls: [BallType.red, BallType.red, BallType.red, BallType.red]),
        Tube(
          balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
        ),
        Tube(),
      ]);
      expect(solvedBoard.isSolved, isTrue);

      // Unsolved: mixed tube
      final unsolvedMixed = BallSortBoard([
        Tube(balls: [BallType.red, BallType.red, BallType.red, BallType.blue]),
        Tube(
          balls: [BallType.blue, BallType.blue, BallType.blue, BallType.red],
        ),
        Tube(),
      ]);
      expect(unsolvedMixed.isSolved, isFalse);

      // Unsolved: partially filled monochrome tube (3 of 4)
      final unsolvedPartial = BallSortBoard([
        Tube(balls: [BallType.red, BallType.red, BallType.red]),
        Tube(balls: [BallType.red]),
        Tube(),
      ]);
      expect(unsolvedPartial.isSolved, isFalse);
    });

    test('board equality and hashCode', () {
      final b1 = BallSortBoard([
        Tube(balls: [BallType.red]),
        Tube(),
      ]);
      final b2 = BallSortBoard([
        Tube(balls: [BallType.red]),
        Tube(),
      ]);
      final b3 = BallSortBoard([
        Tube(balls: [BallType.blue]),
        Tube(),
      ]);

      expect(b1, equals(b2));
      expect(b1.hashCode, equals(b2.hashCode));
      expect(b1, isNot(equals(b3)));
    });

    group('Milestone 0E Grouped Ball Transfers', () {
      test(
        'transfers contiguous same-color balls as a group to empty tube',
        () {
          // Tube 0: Red, Blue, Blue, Blue (3 contiguous blue balls)
          final board = BallSortBoard([
            Tube(
              balls: [
                BallType.red,
                BallType.blue,
                BallType.blue,
                BallType.blue,
              ],
            ),
            Tube(), // Empty (capacity 4)
          ]);

          final result = board.tryMove(0, 1);
          expect(result, isNotNull);
          final (updatedBoard, move) = result!;

          expect(move.ballsMoved, equals(3));
          expect(move.movedBall, equals(BallType.blue));
          expect(
            move.movedBalls,
            equals([BallType.blue, BallType.blue, BallType.blue]),
          );
          expect(updatedBoard.tubes[0].balls, equals([BallType.red]));
          expect(
            updatedBoard.tubes[1].balls,
            equals([BallType.blue, BallType.blue, BallType.blue]),
          );
        },
      );

      test('transfers only up to destination available capacity', () {
        // Tube 0 has 3 Blue balls at top.
        // Tube 1 has 2 Blue balls (capacity 4 -> available space = 2).
        final board = BallSortBoard([
          Tube(
            balls: [BallType.red, BallType.blue, BallType.blue, BallType.blue],
          ),
          Tube(balls: [BallType.blue, BallType.blue]),
        ]);

        final result = board.tryMove(0, 1);
        expect(result, isNotNull);
        final (updatedBoard, move) = result!;

        // Exactly 2 balls moved (min(3, 2) = 2)
        expect(move.ballsMoved, equals(2));
        expect(move.movedBall, equals(BallType.blue));
        expect(
          updatedBoard.tubes[0].balls,
          equals([BallType.red, BallType.blue]),
        );
        expect(
          updatedBoard.tubes[1].balls,
          equals([BallType.blue, BallType.blue, BallType.blue, BallType.blue]),
        );
        expect(updatedBoard.tubes[1].isFull, isTrue);
      });

      test('transfers full 4-ball stack if destination is empty', () {
        final board = BallSortBoard([
          Tube(
            balls: [
              BallType.green,
              BallType.green,
              BallType.green,
              BallType.green,
            ],
          ),
          Tube(),
        ]);

        final result = board.tryMove(0, 1);
        expect(result, isNotNull);
        final (updatedBoard, move) = result!;

        expect(move.ballsMoved, equals(4));
        expect(updatedBoard.tubes[0].isEmpty, isTrue);
        expect(
          updatedBoard.tubes[1].balls,
          equals([
            BallType.green,
            BallType.green,
            BallType.green,
            BallType.green,
          ]),
        );
      });

      test('does not move balls beneath a different color ball', () {
        // Tube 0: Blue, Red, Blue (top ball is single Blue)
        final board = BallSortBoard([
          Tube(balls: [BallType.blue, BallType.red, BallType.blue]),
          Tube(),
        ]);

        final result = board.tryMove(0, 1);
        expect(result, isNotNull);
        final (updatedBoard, move) = result!;

        // Only 1 blue ball transferred
        expect(move.ballsMoved, equals(1));
        expect(
          updatedBoard.tubes[0].balls,
          equals([BallType.blue, BallType.red]),
        );
        expect(updatedBoard.tubes[1].balls, equals([BallType.blue]));
      });
    });
  });
}
