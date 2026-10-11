import 'ball_sort_board.dart';

/// Validates whether a move between two tubes on a [BallSortBoard] is legal.
///
/// A move is legal only when:
/// - Valid tube indices: 0 <= source < board.tubes.length, 0 <= destination < board.tubes.length
/// - source != destination
/// - source is not empty
/// - destination is not full
/// - (destination is empty OR destination top ball matches source top ball)
///
/// Move validation never mutates the board.
class MoveValidator {
  const MoveValidator();

  /// Validates if moving from [sourceTube] to [destinationTube] on [board] is legal.
  bool isValidMove(BallSortBoard board, int sourceTube, int destinationTube) {
    if (!isValidIndex(board, sourceTube) ||
        !isValidIndex(board, destinationTube)) {
      return false;
    }

    if (sourceTube == destinationTube) {
      return false;
    }

    final source = board.tubes[sourceTube];
    final destination = board.tubes[destinationTube];

    if (source.isEmpty) {
      return false;
    }

    if (destination.isFull) {
      return false;
    }

    if (destination.isEmpty) {
      return true;
    }

    return destination.topBall == source.topBall;
  }

  /// Checks if [index] is a valid tube index for [board].
  bool isValidIndex(BallSortBoard board, int index) {
    return index >= 0 && index < board.tubes.length;
  }
}
