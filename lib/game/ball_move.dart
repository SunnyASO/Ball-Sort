import 'package:flutter/foundation.dart';

import 'ball_type.dart';

/// Represents a move between tubes in the Ball Sort puzzle.
@immutable
class BallMove {
  /// Index of the source tube.
  final int sourceTube;

  /// Index of the destination tube.
  final int destinationTube;

  /// Number of balls moved in this action.
  final int ballsMoved;

  /// Identity of the primary ball moved (if recorded).
  final BallType? movedBall;

  /// Ordered list of balls moved in this transfer action (bottom to top).
  final List<BallType> movedBalls;

  const BallMove({
    required this.sourceTube,
    required this.destinationTube,
    this.ballsMoved = 1,
    this.movedBall,
    this.movedBalls = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BallMove &&
        other.sourceTube == sourceTube &&
        other.destinationTube == destinationTube &&
        other.ballsMoved == ballsMoved &&
        other.movedBall == movedBall &&
        listEquals(other.movedBalls, movedBalls);
  }

  @override
  int get hashCode => Object.hash(
    sourceTube,
    destinationTube,
    ballsMoved,
    movedBall,
    Object.hashAll(movedBalls),
  );

  @override
  String toString() =>
      'BallMove(source: $sourceTube -> dest: $destinationTube, count: $ballsMoved, balls: $movedBalls)';
}
