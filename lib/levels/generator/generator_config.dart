import 'package:flutter/foundation.dart';

/// Configuration for procedural level candidate generation and difficulty filtering.
///
/// Keeps logic independent of Flutter widgets and rendering state.
@immutable
class GeneratorConfig {
  /// Number of distinct ball colors/types in the level (2 to 5).
  final int colorCount;

  /// Number of empty helper chambers at start (typically 1 or 2).
  final int emptyTubes;

  /// Capacity of each tube (default 4).
  final int tubeCapacity;

  /// Minimum optimal grouped-move solution length (inclusive), or null if unconstrained.
  final int? minSolutionMoves;

  /// Maximum optimal grouped-move solution length (inclusive), or null if unconstrained.
  final int? maxSolutionMoves;

  /// Minimum normalized color fragmentation in range [0.0, 1.0], or null if unconstrained.
  final double? minFragmentation;

  /// Maximum states the solver is allowed to explore per candidate before rejecting.
  final int maxSolverStates;

  /// Maximum number of generation attempts before returning failure.
  final int maxAttempts;

  const GeneratorConfig({
    required this.colorCount,
    this.emptyTubes = 2,
    this.tubeCapacity = 4,
    this.minSolutionMoves,
    this.maxSolutionMoves,
    this.minFragmentation,
    this.maxSolverStates = 15000,
    this.maxAttempts = 100,
  }) : assert(colorCount >= 2 && colorCount <= 5, 'colorCount must be between 2 and 5'),
       assert(emptyTubes >= 1, 'emptyTubes must be at least 1'),
       assert(tubeCapacity >= 2, 'tubeCapacity must be at least 2'),
       assert(maxAttempts > 0, 'maxAttempts must be positive'),
       assert(maxSolverStates > 0, 'maxSolverStates must be positive');

  /// Total number of chambers (colors + emptyTubes).
  int get totalTubes => colorCount + emptyTubes;

  /// Validates configuration parameters and returns error description if invalid, or null if valid.
  String? validate() {
    if (colorCount < 2 || colorCount > 5) {
      return 'colorCount must be between 2 and 5 (got $colorCount)';
    }
    if (emptyTubes < 1) {
      return 'emptyTubes must be at least 1 (got $emptyTubes)';
    }
    if (tubeCapacity < 2) {
      return 'tubeCapacity must be at least 2 (got $tubeCapacity)';
    }
    if (minSolutionMoves != null &&
        maxSolutionMoves != null &&
        minSolutionMoves! > maxSolutionMoves!) {
      return 'minSolutionMoves ($minSolutionMoves) cannot exceed maxSolutionMoves ($maxSolutionMoves)';
    }
    if (minFragmentation != null &&
        (minFragmentation! < 0.0 || minFragmentation! > 1.0)) {
      return 'minFragmentation must be in [0.0, 1.0] (got $minFragmentation)';
    }
    if (maxAttempts <= 0) {
      return 'maxAttempts must be positive (got $maxAttempts)';
    }
    if (maxSolverStates <= 0) {
      return 'maxSolverStates must be positive (got $maxSolverStates)';
    }
    return null;
  }

  /// Predefined sector templates for standardized difficulty tiers
  static const sector1Training = GeneratorConfig(
    colorCount: 2,
    emptyTubes: 2,
    minSolutionMoves: 5,
    maxSolutionMoves: 9,
    minFragmentation: 0.5,
  );

  static const sector2Intermediate = GeneratorConfig(
    colorCount: 3,
    emptyTubes: 2,
    minSolutionMoves: 9,
    maxSolutionMoves: 13,
    minFragmentation: 0.6,
  );

  static const sector3Advanced = GeneratorConfig(
    colorCount: 4,
    emptyTubes: 2,
    minSolutionMoves: 12,
    maxSolutionMoves: 16,
    minFragmentation: 0.7,
  );

  static const sector4Master = GeneratorConfig(
    colorCount: 5,
    emptyTubes: 2,
    minSolutionMoves: 15,
    maxSolutionMoves: 22,
    minFragmentation: 0.8,
  );
}
