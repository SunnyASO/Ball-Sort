import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/tube.dart';

void main() {
  group('Tube', () {
    test('correct bottom-to-top ordering', () {
      final tube = Tube(balls: [BallType.red, BallType.blue, BallType.green]);

      expect(tube.balls[0], equals(BallType.red));
      expect(tube.balls[1], equals(BallType.blue));
      expect(tube.balls[2], equals(BallType.green));
      expect(tube.balls.first, equals(BallType.red));
      expect(tube.topBall, equals(BallType.green));
    });

    test('empty and full detection', () {
      final emptyTube = Tube();
      expect(emptyTube.isEmpty, isTrue);
      expect(emptyTube.isFull, isFalse);
      expect(emptyTube.count, equals(0));
      expect(emptyTube.availableSpace, equals(4));

      final partialTube = Tube(balls: [BallType.red, BallType.blue]);
      expect(partialTube.isEmpty, isFalse);
      expect(partialTube.isFull, isFalse);
      expect(partialTube.count, equals(2));
      expect(partialTube.availableSpace, equals(2));

      final fullTube = Tube(
        balls: [BallType.red, BallType.blue, BallType.green, BallType.yellow],
      );
      expect(fullTube.isEmpty, isFalse);
      expect(fullTube.isFull, isTrue);
      expect(fullTube.count, equals(4));
      expect(fullTube.availableSpace, equals(0));
    });

    test('correct top ball', () {
      final emptyTube = Tube();
      expect(emptyTube.topBall, isNull);

      final tube = Tube(balls: [BallType.red, BallType.purple]);
      expect(tube.topBall, equals(BallType.purple));
    });

    test('capacity constraints and validation', () {
      expect(() => Tube(capacity: 0), throwsArgumentError);
      expect(() => Tube(capacity: -1), throwsArgumentError);

      expect(
        () => Tube(
          capacity: 2,
          balls: [BallType.red, BallType.blue, BallType.green],
        ),
        throwsArgumentError,
      );

      final fullTube = Tube(capacity: 2, balls: [BallType.red, BallType.blue]);
      expect(() => fullTube.push(BallType.green), throwsStateError);

      final emptyTube = Tube();
      expect(() => emptyTube.pop(), throwsStateError);
    });

    test('empty tube completion', () {
      final emptyTube = Tube();
      expect(emptyTube.isComplete, isTrue);
    });

    test('full monochrome completion', () {
      final fullMonochrome = Tube(
        balls: [BallType.red, BallType.red, BallType.red, BallType.red],
      );
      expect(fullMonochrome.isComplete, isTrue);
    });

    test('mixed tube not complete', () {
      final fullMixed = Tube(
        balls: [BallType.red, BallType.red, BallType.red, BallType.blue],
      );
      expect(fullMixed.isComplete, isFalse);
    });

    test('partially filled monochrome tube not complete', () {
      final partialMonochrome = Tube(
        balls: [BallType.red, BallType.red, BallType.red],
      );
      expect(partialMonochrome.isComplete, isFalse);
    });

    test('external mutation does not affect internal state', () {
      final initialList = [BallType.red, BallType.blue];
      final tube = Tube(balls: initialList);

      // Mutate the external list passed to constructor
      initialList.add(BallType.green);
      expect(tube.balls.length, equals(2));
      expect(tube.balls, equals([BallType.red, BallType.blue]));

      // Attempt mutating the returned collection
      expect(() => tube.balls.add(BallType.yellow), throwsUnsupportedError);
    });

    test('push and pop create new immutable Tube instances', () {
      final tube = Tube(balls: [BallType.red]);
      final pushed = tube.push(BallType.blue);

      expect(tube.balls, equals([BallType.red]));
      expect(pushed.balls, equals([BallType.red, BallType.blue]));

      final popped = pushed.pop();
      expect(popped.balls, equals([BallType.red]));
      expect(pushed.balls, equals([BallType.red, BallType.blue]));
    });

    test('equality and hashCode', () {
      final tube1 = Tube(balls: [BallType.red, BallType.blue]);
      final tube2 = Tube(balls: [BallType.red, BallType.blue]);
      final tube3 = Tube(balls: [BallType.blue, BallType.red]);

      expect(tube1, equals(tube2));
      expect(tube1.hashCode, equals(tube2.hashCode));
      expect(tube1, isNot(equals(tube3)));
    });
  });
}
