import 'dart:math' as math;

import '../../game/ball_move.dart';
import '../../game/ball_sort_board.dart';
import '../../game/ball_type.dart';
import '../../game/board_solver.dart';
import '../../game/move_validator.dart';
import '../../game/tube.dart';
import 'generator_config.dart';
import 'level_isomorphism_hasher.dart';

/// Metadata and board configuration of a verified generated level.
class GeneratedLevel {
  /// The starting playable board.
  final BallSortBoard board;

  /// The deterministic random seed used to generate this level.
  final int seed;

  /// Optimal minimum grouped-move count required to solve the puzzle.
  final int optimalMoves;

  /// Complete verified sequence of optimal moves.
  final List<BallMove> optimalSolution;

  /// Number of states explored by the solver to find the solution.
  final int statesExplored;

  /// Total generation attempts required before finding this valid level.
  final int generationAttempts;

  /// Structural canonical isomorphism hash (invariant under tube and color permutations).
  final String canonicalHash;

  /// Normalized color fragmentation score in range [0.0, 1.0].
  final double fragmentation;

  /// Total contiguous runs of identical color balls.
  final int colorBlocks;

  /// Adjacent color transitions within non-empty tubes.
  final int colorTransitions;

  /// Total generation and verification wall-clock time in milliseconds.
  final int elapsedMs;

  /// The configuration constraints used to generate this level.
  final GeneratorConfig config;

  const GeneratedLevel({
    required this.board,
    required this.seed,
    required this.optimalMoves,
    required this.optimalSolution,
    required this.statesExplored,
    required this.generationAttempts,
    required this.canonicalHash,
    required this.fragmentation,
    required this.colorBlocks,
    required this.colorTransitions,
    required this.elapsedMs,
    required this.config,
  });

  int get colorCount => config.colorCount;
  int get chamberCount => config.totalTubes;
  int get emptyChamberCount => config.emptyTubes;
}

/// Reason for generation failure.
enum GenerationFailureReason {
  invalidConfig,
  attemptsExhausted,
  solverBudgetExhausted,
}

/// Result returned by [LevelGenerator.generateLevel].
class GenerationResult {
  final GeneratedLevel? level;
  final GenerationFailureReason? failureReason;
  final String? errorMessage;
  final int attempts;
  final int elapsedMs;

  const GenerationResult._({
    this.level,
    this.failureReason,
    this.errorMessage,
    required this.attempts,
    required this.elapsedMs,
  });

  factory GenerationResult.success(GeneratedLevel level) {
    return GenerationResult._(
      level: level,
      attempts: level.generationAttempts,
      elapsedMs: level.elapsedMs,
    );
  }

  factory GenerationResult.failure({
    required GenerationFailureReason reason,
    required String message,
    required int attempts,
    required int elapsedMs,
  }) {
    return GenerationResult._(
      failureReason: reason,
      errorMessage: message,
      attempts: attempts,
      elapsedMs: elapsedMs,
    );
  }

  bool get isSuccess => level != null;
  bool get isFailure => !isSuccess;
}

/// Headless, pure Dart generator for original, solver-verified Ball Sort levels.
///
/// Keeps logic independent of Flutter widgets, UI state, animation, and platform services.
class LevelGenerator {
  final BoardSolver solver;
  final LevelIsomorphismHasher hasher;
  final MoveValidator validator;

  const LevelGenerator({
    this.solver = const BoardSolver(),
    this.hasher = const LevelIsomorphismHasher(),
    this.validator = const MoveValidator(),
  });

  /// Generates a single verified level matching [config] using deterministic [seed].
  ///
  /// Rejects candidates that:
  /// - Are already solved.
  /// - Contain already completed tubes.
  /// - Have no legal initial moves.
  /// - Do not satisfy solution length constraints.
  /// - Do not satisfy minimum fragmentation constraints.
  /// - Match any canonical hash in [existingHashes].
  GenerationResult generateLevel({
    required GeneratorConfig config,
    required int seed,
    Set<String> existingHashes = const {},
  }) {
    final sw = Stopwatch()..start();

    final configError = config.validate();
    if (configError != null) {
      sw.stop();
      return GenerationResult.failure(
        reason: GenerationFailureReason.invalidConfig,
        message: configError,
        attempts: 0,
        elapsedMs: sw.elapsedMilliseconds,
      );
    }

    final rng = math.Random(seed);
    int attempts = 0;

    while (attempts < config.maxAttempts) {
      attempts++;

      // 1. Build initial pool of balls (exactly 4 balls per color)
      final ballPool = <BallType>[];
      for (int c = 0; c < config.colorCount; c++) {
        final color = BallType.values[c];
        for (int b = 0; b < config.tubeCapacity; b++) {
          ballPool.add(color);
        }
      }

      // 2. Deterministic Fisher-Yates shuffle
      _shuffle(ballPool, rng);

      // 3. Partition into tubes
      final tubes = <Tube>[];
      for (int t = 0; t < config.colorCount; t++) {
        final start = t * config.tubeCapacity;
        final tubeBalls = ballPool.sublist(start, start + config.tubeCapacity);
        tubes.add(Tube(capacity: config.tubeCapacity, balls: tubeBalls));
      }

      // 4. Add empty helper tubes
      for (int e = 0; e < config.emptyTubes; e++) {
        tubes.add(Tube(capacity: config.tubeCapacity));
      }

      final candidateBoard = BallSortBoard(tubes);

      // 5. Invariant check: must not be already solved
      if (candidateBoard.isSolved) {
        continue;
      }

      // 6. Invariant check: no individual tube should start complete
      if (candidateBoard.tubes.any((t) => !t.isEmpty && t.isComplete)) {
        continue;
      }

      // 7. Invariant check: at least one legal move must exist
      if (!_hasLegalMoves(candidateBoard)) {
        continue;
      }

      // 8. Measure fragmentation
      final (blocks, transitions, normFrag) = _computeFragmentation(
        candidateBoard,
        config.colorCount,
        config.tubeCapacity,
      );

      if (config.minFragmentation != null &&
          normFrag < config.minFragmentation!) {
        continue;
      }

      // 9. Verify solvability with the corrected solver
      final (solution, statesExplored) = solver.solveWithStats(
        candidateBoard,
        maxStates: config.maxSolverStates,
      );

      if (solution == null) {
        continue; // Unsolvable or exceeded solver budget
      }

      // 10. Check solution length bounds
      if (config.minSolutionMoves != null &&
          solution.length < config.minSolutionMoves!) {
        continue;
      }
      if (config.maxSolutionMoves != null &&
          solution.length > config.maxSolutionMoves!) {
        continue;
      }

      // 11. Deduplication and isomorphism check
      final hash = hasher.canonicalHash(candidateBoard);
      if (existingHashes.contains(hash)) {
        continue; // Equivalent level already exists
      }

      sw.stop();
      return GenerationResult.success(
        GeneratedLevel(
          board: candidateBoard,
          seed: seed,
          optimalMoves: solution.length,
          optimalSolution: solution,
          statesExplored: statesExplored,
          generationAttempts: attempts,
          canonicalHash: hash,
          fragmentation: normFrag,
          colorBlocks: blocks,
          colorTransitions: transitions,
          elapsedMs: sw.elapsedMilliseconds,
          config: config,
        ),
      );
    }

    sw.stop();
    return GenerationResult.failure(
      reason: GenerationFailureReason.attemptsExhausted,
      message:
          'Exhausted ${config.maxAttempts} attempts without finding a candidate satisfying all constraints',
      attempts: attempts,
      elapsedMs: sw.elapsedMilliseconds,
    );
  }

  /// Measures empirical solvability yield for a given configuration across [sampleCount] seeds.
  Map<String, dynamic> benchmarkConfiguration({
    required int colorCount,
    required int emptyTubes,
    int sampleCount = 50,
    int seedOffset = 1000,
    int maxSolverStates = 15000,
  }) {
    int solvableCount = 0;
    int totalTimeMs = 0;
    final moveLengths = <int>[];

    final config = GeneratorConfig(
      colorCount: colorCount,
      emptyTubes: emptyTubes,
      maxSolverStates: maxSolverStates,
    );

    for (int i = 0; i < sampleCount; i++) {
      final seed = seedOffset + i;
      final sw = Stopwatch()..start();
      final result = generateLevel(config: config, seed: seed);
      sw.stop();
      totalTimeMs += sw.elapsedMilliseconds;

      if (result.isSuccess) {
        solvableCount++;
        moveLengths.add(result.level!.optimalMoves);
      }
    }

    final double avgMoves = moveLengths.isEmpty
        ? 0.0
        : moveLengths.reduce((a, b) => a + b) / moveLengths.length;

    return {
      'colorCount': colorCount,
      'emptyTubes': emptyTubes,
      'sampleCount': sampleCount,
      'solvableCount': solvableCount,
      'yieldPercentage': (solvableCount / sampleCount) * 100.0,
      'avgTimeMs': totalTimeMs / sampleCount,
      'avgOptimalMoves': avgMoves,
    };
  }

  bool _hasLegalMoves(BallSortBoard board) {
    final n = board.tubeCount;
    for (int i = 0; i < n; i++) {
      if (board.tubes[i].isEmpty) continue;
      for (int j = 0; j < n; j++) {
        if (i == j) continue;
        if (validator.isValidMove(board, i, j)) {
          return true;
        }
      }
    }
    return false;
  }

  (int, int, double) _computeFragmentation(
    BallSortBoard board,
    int colorCount,
    int capacity,
  ) {
    int colorBlocks = 0;
    int colorTransitions = 0;

    for (final tube in board.tubes) {
      if (tube.isEmpty) continue;
      BallType? lastBall;
      for (final ball in tube.balls) {
        if (lastBall == null) {
          colorBlocks++;
        } else if (lastBall != ball) {
          colorBlocks++;
          colorTransitions++;
        }
        lastBall = ball;
      }
    }

    // Min blocks = colorCount (if all tubes were monochrome)
    // Max blocks = colorCount * capacity (if every adjacent ball was distinct)
    final maxBlocks = colorCount * capacity;
    final minBlocks = colorCount;
    final denominator = (maxBlocks - minBlocks) <= 0 ? 1 : (maxBlocks - minBlocks);
    final normFrag = ((colorBlocks - minBlocks) / denominator).clamp(0.0, 1.0);

    return (colorBlocks, colorTransitions, normFrag);
  }

  void _shuffle<T>(List<T> list, math.Random rng) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }
}
