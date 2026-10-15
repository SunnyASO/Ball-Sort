// ignore_for_file: avoid_print
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/levels/generator/generator_config.dart';
import 'package:ball_sort/levels/generator/level_generator.dart';
import 'package:ball_sort/levels/generator/level_isomorphism_hasher.dart';
import 'package:ball_sort/levels/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelGenerator Unit & Headless Tests', () {
    const generator = LevelGenerator();
    const hasher = LevelIsomorphismHasher();

    test('determinism: same seed and config produce identical board and metadata', () {
      const config = GeneratorConfig(colorCount: 3, emptyTubes: 2);
      const seed = 12345;

      final res1 = generator.generateLevel(config: config, seed: seed);
      final res2 = generator.generateLevel(config: config, seed: seed);

      expect(res1.isSuccess, isTrue);
      expect(res2.isSuccess, isTrue);

      final l1 = res1.level!;
      final l2 = res2.level!;

      expect(l1.seed, equals(l2.seed));
      expect(l1.optimalMoves, equals(l2.optimalMoves));
      expect(l1.canonicalHash, equals(l2.canonicalHash));
      expect(l1.board, equals(l2.board));
      expect(l1.optimalSolution.length, equals(l2.optimalSolution.length));

      for (int i = 0; i < l1.optimalSolution.length; i++) {
        expect(l1.optimalSolution[i], equals(l2.optimalSolution[i]));
      }
    });

    test('invariants: every generated level satisfies strict conservation and board rules', () {
      const configs = [
        GeneratorConfig.sector1Training,
        GeneratorConfig.sector2Intermediate,
        GeneratorConfig.sector3Advanced,
        GeneratorConfig.sector4Master,
      ];

      for (int i = 0; i < configs.length; i++) {
        final res = generator.generateLevel(config: configs[i], seed: 777 + i);
        expect(res.isSuccess, isTrue, reason: 'Config $i must succeed');

        final level = res.level!;
        final board = level.board;

        // Tube count
        expect(board.tubeCount, equals(configs[i].totalTubes));

        // Empty tubes count
        final emptyCount = board.tubes.where((t) => t.isEmpty).length;
        expect(emptyCount, equals(configs[i].emptyTubes));

        // Total ball count = 4 * colorCount
        expect(board.totalBallCount, equals(configs[i].colorCount * 4));

        // Exact 4 balls per color
        final colorCounts = <BallType, int>{};
        for (final tube in board.tubes) {
          expect(tube.capacity, equals(4));
          for (final b in tube.balls) {
            colorCounts[b] = (colorCounts[b] ?? 0) + 1;
          }
        }
        expect(colorCounts.length, equals(configs[i].colorCount));
        for (final count in colorCounts.values) {
          expect(count, equals(4));
        }

        // Never starts already solved
        expect(board.isSolved, isFalse);

        // No individual tube starts already complete
        for (final tube in board.tubes) {
          if (!tube.isEmpty) {
            expect(tube.isComplete, isFalse);
          }
        }

        // Must satisfy solution length constraints if configured
        if (configs[i].minSolutionMoves != null) {
          expect(level.optimalMoves, greaterThanOrEqualTo(configs[i].minSolutionMoves!));
        }
        if (configs[i].maxSolutionMoves != null) {
          expect(level.optimalMoves, lessThanOrEqualTo(configs[i].maxSolutionMoves!));
        }

        // Must satisfy minimum fragmentation if configured
        if (configs[i].minFragmentation != null) {
          expect(level.fragmentation, greaterThanOrEqualTo(configs[i].minFragmentation!));
        }
      }
    });

    test('solvability and replay: replaying solution reaches victory state', () {
      const config = GeneratorConfig(colorCount: 4, emptyTubes: 2);
      final res = generator.generateLevel(config: config, seed: 9999);
      expect(res.isSuccess, isTrue);

      final level = res.level!;
      var current = level.board;

      for (final move in level.optimalSolution) {
        final step = current.tryMove(move.sourceTube, move.destinationTube);
        expect(step, isNotNull, reason: 'Every generated solution move must be legal');
        current = step!.$1;
      }

      expect(current.isSolved, isTrue, reason: 'Replaying full solution must solve board');
    });

    test('deduplication: rejects duplicate or color-isomorphic candidates', () {
      const config = GeneratorConfig(colorCount: 3, emptyTubes: 2);
      final res1 = generator.generateLevel(config: config, seed: 101);
      expect(res1.isSuccess, isTrue);

      final hash1 = res1.level!.canonicalHash;

      // When providing hash1 in existingHashes, generator must not produce an isomorphic board
      final res2 = generator.generateLevel(
        config: config,
        seed: 101, // same seed would naturally produce hash1 on attempt 1
        existingHashes: {hash1},
      );

      expect(res2.isSuccess, isTrue);
      expect(res2.level!.canonicalHash, isNot(equals(hash1)));
      expect(hasher.areIsomorphic(res1.level!.board, res2.level!.board), isFalse);
      expect(res2.level!.generationAttempts, greaterThan(1));
    });

    test('budget exhaustion: returns explicit failure when constraints are unsatisfiable', () {
      // Impossible constraint: 5 colors, 2 empty tubes, but requiring >= 50 moves within 3 attempts
      const impossibleConfig = GeneratorConfig(
        colorCount: 5,
        emptyTubes: 2,
        minSolutionMoves: 50,
        maxAttempts: 3,
      );

      final res = generator.generateLevel(config: impossibleConfig, seed: 42);
      expect(res.isFailure, isTrue);
      expect(res.failureReason, equals(GenerationFailureReason.attemptsExhausted));
      expect(res.level, isNull);
    });

    test('benchmarks empirical yield: 1-empty-tube vs 2-empty-tubes', () {
      // Benchmark 1 empty tube
      final yield1Empty = generator.benchmarkConfiguration(
        colorCount: 3,
        emptyTubes: 1,
        sampleCount: 20,
        seedOffset: 5000,
      );

      // Benchmark 2 empty tubes
      final yield2Empty = generator.benchmarkConfiguration(
        colorCount: 3,
        emptyTubes: 2,
        sampleCount: 20,
        seedOffset: 6000,
      );

      print('Empirical Benchmark:');
      print('  3 colors, 1 empty: yield = ${yield1Empty['yieldPercentage']}%, avg moves = ${yield1Empty['avgOptimalMoves']}, avg time = ${yield1Empty['avgTimeMs']}ms');
      print('  3 colors, 2 empty: yield = ${yield2Empty['yieldPercentage']}%, avg moves = ${yield2Empty['avgOptimalMoves']}, avg time = ${yield2Empty['avgTimeMs']}ms');

      expect(yield1Empty['sampleCount'], equals(20));
      expect(yield2Empty['sampleCount'], equals(20));
      expect(yield2Empty['yieldPercentage'], equals(100.0));
    });

    test('Phase C: generates 10 novel test puzzles across feasible tiers and validates all criteria', () {
      // Collect existing canonical hashes from Levels 1 to 20 to ensure 100% novelty
      final existingCatalogHashes = <String>{};
      for (int i = 1; i <= LevelCatalog.totalLevels; i++) {
        existingCatalogHashes.add(hasher.canonicalHash(LevelCatalog.getLevel(i)));
      }

      final tierConfigs = [
        // Sector 1: Training (2-3 colors)
        const GeneratorConfig(colorCount: 2, emptyTubes: 2, minSolutionMoves: 5, maxSolutionMoves: 7),
        const GeneratorConfig(colorCount: 2, emptyTubes: 2, minSolutionMoves: 5, maxSolutionMoves: 7),
        const GeneratorConfig(colorCount: 3, emptyTubes: 2, minSolutionMoves: 7, maxSolutionMoves: 10),
        // Sector 2: Intermediate (3-4 colors)
        const GeneratorConfig(colorCount: 3, emptyTubes: 2, minSolutionMoves: 8, maxSolutionMoves: 11),
        const GeneratorConfig(colorCount: 3, emptyTubes: 2, minSolutionMoves: 9, maxSolutionMoves: 12),
        const GeneratorConfig(colorCount: 4, emptyTubes: 2, minSolutionMoves: 11, maxSolutionMoves: 14),
        // Sector 3: Advanced (4-5 colors)
        const GeneratorConfig(colorCount: 4, emptyTubes: 2, minSolutionMoves: 12, maxSolutionMoves: 15),
        const GeneratorConfig(colorCount: 4, emptyTubes: 2, minSolutionMoves: 13, maxSolutionMoves: 16),
        // Sector 4: Master (5 colors)
        const GeneratorConfig(colorCount: 5, emptyTubes: 2, minSolutionMoves: 14, maxSolutionMoves: 18),
        const GeneratorConfig(colorCount: 5, emptyTubes: 2, minSolutionMoves: 15, maxSolutionMoves: 20),
      ];

      expect(tierConfigs.length, equals(10));

      final batch = <GeneratedLevel>[];
      final batchHashes = Set<String>.from(existingCatalogHashes);

      print('\n=== PHASE C: GENERATED 10-LEVEL SAMPLE BATCH ===');
      print('Idx | Colors | Tubes | Empty | Moves | Frag  | Blocks | Trans | Att | Time(ms) | Novel vs Catalog');
      print('----+--------+-------+-------+-------+-------+--------+-------+-----+----------+-----------------');

      for (int i = 0; i < tierConfigs.length; i++) {
        final config = tierConfigs[i];
        final seed = 20261015 + i * 17;

        final result = generator.generateLevel(
          config: config,
          seed: seed,
          existingHashes: batchHashes,
        );

        expect(
          result.isSuccess,
          isTrue,
          reason: 'Level index $i must successfully generate a candidate: ${result.errorMessage}',
        );

        final level = result.level!;
        batch.add(level);
        batchHashes.add(level.canonicalHash);

        // 1. Verify board invariants
        expect(level.board.tubeCount, equals(config.totalTubes));
        expect(level.board.totalBallCount, equals(config.colorCount * 4));
        expect(level.board.isSolved, isFalse);

        // 2. Verify solver confirmed solvability
        expect(level.optimalSolution.isNotEmpty, isTrue);
        expect(level.optimalMoves, equals(level.optimalSolution.length));

        // 3 & 4. Verify each move is legal and replay to victory
        var current = level.board;
        for (final move in level.optimalSolution) {
          final res = current.tryMove(move.sourceTube, move.destinationTube);
          expect(res, isNotNull, reason: 'Level $i: move must be valid');
          current = res!.$1;
        }
        expect(current.isSolved, isTrue, reason: 'Level $i: replay must solve board');

        // 5. Verify determinism by regenerating with same seed
        final verifyDeterminism = generator.generateLevel(
          config: config,
          seed: seed,
          existingHashes: {},
        );
        expect(verifyDeterminism.level!.board, equals(level.board));
        expect(verifyDeterminism.level!.canonicalHash, equals(level.canonicalHash));

        // 6. Verify no collisions with existing 20 levels
        expect(
          existingCatalogHashes.contains(level.canonicalHash),
          isFalse,
          reason: 'Level $i must be strictly novel and not isomorphic to existing Levels 1-20',
        );

        print(
          '${(i + 1).toString().padLeft(3)} | '
          '${level.colorCount.toString().padLeft(6)} | '
          '${level.chamberCount.toString().padLeft(5)} | '
          '${level.emptyChamberCount.toString().padLeft(5)} | '
          '${level.optimalMoves.toString().padLeft(5)} | '
          '${level.fragmentation.toStringAsFixed(2).padLeft(5)} | '
          '${level.colorBlocks.toString().padLeft(6)} | '
          '${level.colorTransitions.toString().padLeft(5)} | '
          '${level.generationAttempts.toString().padLeft(3)} | '
          '${level.elapsedMs.toString().padLeft(8)} | '
          'YES (Unique)'
        );
      }

      expect(batch.length, equals(10));

      // Verify mutual non-isomorphism across the entire generated batch
      for (int i = 0; i < batch.length; i++) {
        for (int j = i + 1; j < batch.length; j++) {
          expect(
            batch[i].canonicalHash,
            isNot(equals(batch[j].canonicalHash)),
            reason: 'Generated Level $i and $j must not be isomorphic',
          );
        }
      }
    });
  });
}
