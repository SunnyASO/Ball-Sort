import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'ball_move.dart';
import 'ball_type.dart';
import 'move_validator.dart';
import 'tube.dart';

/// Represents the board state in the Ball Sort puzzle.
/// Manages an immutable list of [Tube]s and executes deterministic moves.
@immutable
class BallSortBoard {
  final List<Tube> _tubes;

  /// Creates a [BallSortBoard] with the given [tubes].
  /// Collections are unmodifiable to prevent external mutation.
  BallSortBoard(Iterable<Tube> tubes) : _tubes = List.unmodifiable(tubes);

  /// An unmodifiable list of tubes on the board.
  List<Tube> get tubes => _tubes;

  /// Total number of tubes on the board.
  int get tubeCount => _tubes.length;

  /// Total count of balls across all tubes on the board.
  int get totalBallCount =>
      _tubes.fold(0, (sum, tube) => sum + tube.balls.length);

  /// Checks if the puzzle is solved.
  /// The board is solved when EVERY tube is complete:
  /// - Either empty; OR
  /// - Full and containing only one ball type.
  bool get isSolved {
    if (_tubes.isEmpty) return false;
    for (final tube in _tubes) {
      if (!tube.isComplete) return false;
    }
    return true;
  }

  /// Attempts to perform a deterministic ball transfer from [sourceIndex]
  /// to [destinationIndex].
  ///
  /// For Milestone 0E grouped movement:
  /// Transfers as many contiguous matching top balls as can fit in the destination:
  /// transferCount = min(source.topMatchingCount, destination.availableSpace)
  ///
  /// If the move is valid:
  /// - Pops transferCount balls from source
  /// - Pushes transferCount balls to destination
  /// - Returns a record `(updatedBoard, move)`
  ///
  /// If the move is invalid:
  /// - Leaves the board unchanged
  /// - Returns `null`
  (BallSortBoard, BallMove)? tryMove(
    int sourceIndex,
    int destinationIndex, {
    MoveValidator validator = const MoveValidator(),
  }) {
    if (!validator.isValidMove(this, sourceIndex, destinationIndex)) {
      return null;
    }

    final source = _tubes[sourceIndex];
    final destination = _tubes[destinationIndex];
    final movingBall = source.topBall!;

    final transferCount = math.min(
      source.topMatchingCount,
      destination.availableSpace,
    );

    if (transferCount <= 0) {
      return null;
    }

    final movedBalls = List<BallType>.filled(transferCount, movingBall);

    // Pop transferCount balls from source
    final updatedSourceBalls = source.balls.sublist(
      0,
      source.balls.length - transferCount,
    );
    final updatedSource = source.copyWith(balls: updatedSourceBalls);

    // Push transferCount balls to destination
    final updatedDestBalls = [...destination.balls, ...movedBalls];
    final updatedDestination = destination.copyWith(balls: updatedDestBalls);

    final updatedTubes = List<Tube>.of(_tubes);
    updatedTubes[sourceIndex] = updatedSource;
    updatedTubes[destinationIndex] = updatedDestination;

    return (
      BallSortBoard(updatedTubes),
      BallMove(
        sourceTube: sourceIndex,
        destinationTube: destinationIndex,
        ballsMoved: transferCount,
        movedBall: movingBall,
        movedBalls: movedBalls,
      ),
    );
  }

  /// Deep copy or recreate board from existing tubes.
  BallSortBoard copyWith({Iterable<Tube>? tubes}) {
    return BallSortBoard(tubes ?? _tubes);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BallSortBoard) return false;
    if (_tubes.length != other._tubes.length) return false;
    for (var i = 0; i < _tubes.length; i++) {
      if (_tubes[i] != other._tubes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_tubes);

  @override
  String toString() => 'BallSortBoard(tubes: $_tubes)';
}
