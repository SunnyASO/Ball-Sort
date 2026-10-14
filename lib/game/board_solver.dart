import 'dart:collection';

import 'ball_move.dart';
import 'ball_sort_board.dart';
import 'move_validator.dart';

/// Search-based solver for Ball Sort puzzle boards using Breadth-First Search (BFS).
///
/// Implements canonical state hashing and pruning of symmetric tubes (such as
/// multiple empty tubes) to eliminate redundant search branches.
class BoardSolver {
  final MoveValidator validator;

  const BoardSolver({this.validator = const MoveValidator()});

  /// Computes a canonical signature for a board configuration.
  /// Sorts empty tubes and identical tubes so equivalent permutations are not explored repeatedly.
  static String canonicalKey(BallSortBoard board) {
    final tubeStrings = board.tubes.map((t) {
      if (t.isEmpty) return 'E';
      return t.balls.map((b) => b.index).join(',');
    }).toList();

    // Sort to canonicalize tube ordering and prevent permutation explosion
    tubeStrings.sort();
    return tubeStrings.join('|');
  }

  /// Finds the shortest legal move sequence to solve [board], or `null` if unsolvable.
  List<BallMove>? solve(BallSortBoard initialBoard, {int maxStates = 15000}) {
    if (initialBoard.isSolved) {
      return [];
    }

    final queue = Queue<(BallSortBoard, List<BallMove>)>();
    final visited = <String>{};

    queue.add((initialBoard, []));
    visited.add(canonicalKey(initialBoard));

    int statesExplored = 0;

    while (queue.isNotEmpty && statesExplored < maxStates) {
      final (currentBoard, moves) = queue.removeFirst();
      statesExplored++;

      if (currentBoard.isSolved) {
        return moves;
      }

      final n = currentBoard.tubeCount;
      bool exploredEmptyDest = false;

      for (int i = 0; i < n; i++) {
        final sourceTube = currentBoard.tubes[i];
        if (sourceTube.isEmpty) continue;
        // Optimization: don't move from an already completed monochrome full tube
        if (sourceTube.isComplete) continue;

        for (int j = 0; j < n; j++) {
          if (i == j) continue;
          final destTube = currentBoard.tubes[j];

          // If moving to an empty tube, only explore the first empty tube encountered
          // because all empty tubes are structurally symmetric
          if (destTube.isEmpty) {
            if (exploredEmptyDest) continue;
            // Also don't move from a tube that is already monochromatic onto an empty tube
            if (sourceTube.balls.every((b) => b == sourceTube.balls.first)) {
              continue;
            }
          }

          if (validator.isValidMove(currentBoard, i, j)) {
            final result = currentBoard.tryMove(i, j, validator: validator);
            if (result != null) {
              final (nextBoard, move) = result;
              final key = canonicalKey(nextBoard);

              if (!visited.contains(key)) {
                visited.add(key);
                if (nextBoard.isSolved) {
                  return [...moves, move];
                }
                queue.add((nextBoard, [...moves, move]));
              }

              if (destTube.isEmpty) {
                exploredEmptyDest = true;
              }
            }
          }
        }
      }
    }

    return null;
  }

  /// Returns the next single optimal [BallMove] towards solving [board],
  /// or `null` if already solved or unsolvable.
  BallMove? getNextOptimalMove(BallSortBoard board) {
    final solution = solve(board);
    if (solution == null || solution.isEmpty) {
      return null;
    }
    return solution.first;
  }

  /// Checks whether [board] has a verified solution.
  bool isSolvable(BallSortBoard board) {
    return solve(board) != null;
  }
}
