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
  List<BallMove>? solve(BallSortBoard initialBoard, {int maxStates = 30000}) {
    return solveWithStats(initialBoard, maxStates: maxStates).$1;
  }

  /// Solves [board] and returns a detailed [SolverResult] distinguishing
  /// between solved, definitively unsolvable, and budget-exceeded configurations.
  SolverResult solveDetailed(
    BallSortBoard initialBoard, {
    int maxStates = 30000,
  }) {
    final (solution, statesExplored) = solveWithStats(
      initialBoard,
      maxStates: maxStates,
    );
    final exceeded = solution == null && statesExplored >= maxStates;
    return SolverResult(
      solution: solution,
      statesExplored: statesExplored,
      exceededBudget: exceeded,
    );
  }

  /// Solves [board] and returns a record containing the optimal [BallMove] sequence (or `null`)
  /// and the total count of search states explored.
  (List<BallMove>?, int statesExplored) solveWithStats(
    BallSortBoard initialBoard, {
    int maxStates = 30000,
  }) {
    if (initialBoard.isSolved) {
      return ([], 0);
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
        return (moves, statesExplored);
      }

      final n = currentBoard.tubeCount;

      for (int i = 0; i < n; i++) {
        final sourceTube = currentBoard.tubes[i];
        if (sourceTube.isEmpty) continue;
        // Optimization: don't move from an already completed monochrome full tube
        if (sourceTube.isComplete) continue;

        // Symmetry pruning: for this specific source tube, only explore transferring
        // to the first empty destination chamber encountered, since transferring to
        // any empty chamber produces an identical canonical board state.
        bool exploredEmptyDest = false;

        for (int j = 0; j < n; j++) {
          if (i == j) continue;
          final destTube = currentBoard.tubes[j];

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
                  return ([...moves, move], statesExplored);
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

    return (null, statesExplored);
  }

  /// Returns the next single optimal [BallMove] towards solving [board],
  /// or `null` if already solved or unsolvable.
  BallMove? getNextOptimalMove(
    BallSortBoard board, {
    int maxStates = 30000,
  }) {
    final solution = solve(board, maxStates: maxStates);
    if (solution == null || solution.isEmpty) {
      return null;
    }
    return solution.first;
  }

  /// Checks whether [board] has a verified solution.
  bool isSolvable(BallSortBoard board, {int maxStates = 30000}) {
    return solve(board, maxStates: maxStates) != null;
  }
}

/// Encapsulates the complete result of a solver search.
class SolverResult {
  /// The shortest legal sequence of moves to victory, or `null` if no solution was found.
  final List<BallMove>? solution;

  /// Total count of board states expanded during search.
  final int statesExplored;

  /// True if the search terminated because it exceeded the state budget rather than
  /// exhausting all reachable states in the graph.
  final bool exceededBudget;

  const SolverResult({
    required this.solution,
    required this.statesExplored,
    required this.exceededBudget,
  });

  /// True if a verified solution sequence was found.
  bool get isSolved => solution != null;

  /// True ONLY if the search space was fully exhausted without finding a solution.
  bool get isUnsolvable => solution == null && !exceededBudget;
}

/// Message payload for background isolate solver execution.
class SolverRequest {
  final BallSortBoard board;
  final int maxStates;

  const SolverRequest(this.board, {this.maxStates = 30000});
}

/// Top-level worker function executing solver search on a background isolate via [compute].
SolverResult solveBoardInWorker(SolverRequest request) {
  const solver = BoardSolver();
  return solver.solveDetailed(request.board, maxStates: request.maxStates);
}

