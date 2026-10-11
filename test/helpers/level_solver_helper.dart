import 'dart:collection';

import 'package:ball_sort/game/ball_move.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/move_validator.dart';

/// Test/development solver to find shortest valid move sequences.
/// Uses Breadth-First Search (BFS) over board states.
class LevelSolverHelper {
  final MoveValidator validator = const MoveValidator();

  /// Finds the shortest legal move sequence to solve [board], or null if unsolvable.
  List<BallMove>? solve(BallSortBoard initialBoard) {
    if (initialBoard.isSolved) return [];

    final queue = Queue<(BallSortBoard, List<BallMove>)>();
    final visited = <String>{};

    String boardKey(BallSortBoard b) {
      return b.tubes
          .map((t) => t.balls.map((ball) => ball.index).join(','))
          .join(';');
    }

    queue.add((initialBoard, []));
    visited.add(boardKey(initialBoard));

    while (queue.isNotEmpty) {
      final (currentBoard, moves) = queue.removeFirst();

      if (currentBoard.isSolved) {
        return moves;
      }

      final n = currentBoard.tubeCount;
      for (int i = 0; i < n; i++) {
        if (currentBoard.tubes[i].isEmpty) continue;
        for (int j = 0; j < n; j++) {
          if (i == j) continue;
          if (validator.isValidMove(currentBoard, i, j)) {
            final result = currentBoard.tryMove(i, j, validator: validator);
            if (result != null) {
              final (nextBoard, move) = result;
              final key = boardKey(nextBoard);
              if (!visited.contains(key)) {
                visited.add(key);
                queue.add((nextBoard, [...moves, move]));
              }
            }
          }
        }
      }
    }

    return null;
  }
}
