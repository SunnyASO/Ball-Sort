import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/move_validator.dart';
import 'package:ball_sort/game/tube.dart';

void main() {
  group('MoveValidator', () {
    const validator = MoveValidator();

    test('empty source rejected', () {
      final board = BallSortBoard([
        Tube(), // 0: empty
        Tube(balls: [BallType.red]), // 1: non-empty
      ]);

      expect(validator.isValidMove(board, 0, 1), isFalse);
    });

    test('full destination rejected', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red]), // 0
        Tube(
          balls: [BallType.red, BallType.red, BallType.red, BallType.red],
        ), // 1: full
      ]);

      expect(validator.isValidMove(board, 0, 1), isFalse);
    });

    test('empty destination accepted', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red, BallType.blue]), // 0: top is blue
        Tube(), // 1: empty
      ]);

      expect(validator.isValidMove(board, 0, 1), isTrue);
    });

    test('matching destination accepted', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red, BallType.blue]), // 0: top is blue
        Tube(balls: [BallType.yellow, BallType.blue]), // 1: top is blue
      ]);

      expect(validator.isValidMove(board, 0, 1), isTrue);
    });

    test('mismatched destination rejected', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red, BallType.blue]), // 0: top is blue
        Tube(balls: [BallType.blue, BallType.red]), // 1: top is red
      ]);

      expect(validator.isValidMove(board, 0, 1), isFalse);
    });

    test('same source and destination rejected', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red, BallType.blue]),
      ]);

      expect(validator.isValidMove(board, 0, 0), isFalse);
    });

    test('invalid indices rejected', () {
      final board = BallSortBoard([
        Tube(balls: [BallType.red]),
        Tube(),
      ]);

      expect(validator.isValidMove(board, -1, 1), isFalse);
      expect(validator.isValidMove(board, 0, 2), isFalse);
      expect(validator.isValidMove(board, 5, 6), isFalse);
    });
  });
}
