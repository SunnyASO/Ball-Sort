import 'package:flutter/foundation.dart';

import '../game/ball_sort_board.dart';
import '../game/board_solver.dart';

/// Service managing non-blocking, isolate-accelerated hint calculations.
///
/// Implements a hybrid execution strategy:
/// 1. Runs a lightweight synchronous check up to [fastThreshold] states (~0.2ms)
///    to eliminate isolate message serialization overhead on easy/small configurations.
/// 2. If the puzzle complexity requires deep graph exploration, offloads execution
///    to a background worker isolate via [compute] to guarantee 60/120 FPS UI fluidity.
class HintService {
  static final HintService instance = HintService._internal();

  HintService._internal();

  /// Requests an optimal move calculation towards board victory.
  ///
  /// Returns a [SolverResult] indicating whether a solution was found,
  /// whether the board is definitively unsolvable, or whether the search budget was reached.
  Future<SolverResult> requestHint({
    required BallSortBoard board,
    int fastThreshold = 150,
    int maxStates = 30000,
  }) async {
    if (board.isSolved) {
      return const SolverResult(
        solution: [],
        statesExplored: 0,
        exceededBudget: false,
      );
    }

    // 1. Fast bounded check on UI isolate (< 0.2ms) to avoid isolate dispatch overhead
    const solver = BoardSolver();
    final fastResult = solver.solveDetailed(board, maxStates: fastThreshold);
    if (fastResult.isSolved || fastResult.isUnsolvable) {
      return fastResult;
    }

    // 2. Heavy search: offload to background worker isolate
    return compute(
      solveBoardInWorker,
      SolverRequest(board, maxStates: maxStates),
    );
  }
}
