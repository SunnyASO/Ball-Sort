import '../game/ball_sort_board.dart';
import '../game/ball_type.dart';
import '../game/tube.dart';
import 'prototype_levels.dart';

/// Comprehensive curated level catalog across all 10 Orb Lab Sectors (Levels 1 to 50).
///
/// Features:
/// - Sector 1: Training Protocols (Levels 1 - 5)
/// - Sector 2: Intermediate Containment (Levels 6 - 10)
/// - Sector 3: Advanced Plasma Routing (Levels 11 - 15)
/// - Sector 4: Quantum Isolation (Levels 16 - 20)
/// - Sector 5: Entropy Calibration (Levels 21 - 25)
/// - Sector 6: Resonance Flux (Levels 26 - 30)
/// - Sector 7: Subatomic Synthesis (Levels 31 - 35)
/// - Sector 8: Magnetic Chambering (Levels 36 - 40)
/// - Sector 9: Superposition Routing (Levels 41 - 45)
/// - Sector 10: Singularity Isolation (Levels 46 - 50)
///
/// Every level satisfies:
/// - Tube capacity is 4.
/// - Every color used appears exactly 4 times in total.
/// - Valid starting moves exist.
/// - Board is not solved at start.
/// - 100% solvable through legal moves.
class LevelCatalog {
  const LevelCatalog._();

  /// Total number of curated levels across all sectors.
  static const int totalLevels = 50;

  /// Retrieves the board for [levelNumber] (1-indexed, 1..20).
  static BallSortBoard getLevel(int levelNumber) {
    if (levelNumber < 1 || levelNumber > totalLevels) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'Level must be between 1 and $totalLevels',
      );
    }

    if (levelNumber <= PrototypeLevels.totalLevels) {
      return PrototypeLevels.getLevel(levelNumber);
    }

    switch (levelNumber) {
      case 7:
        return level7;
      case 8:
        return level8;
      case 9:
        return level9;
      case 10:
        return level10;
      case 11:
        return level11;
      case 12:
        return level12;
      case 13:
        return level13;
      case 14:
        return level14;
      case 15:
        return level15;
      case 16:
        return level16;
      case 17:
        return level17;
      case 18:
        return level18;
      case 19:
        return level19;
      case 20:
        return level20;
      case 21:
        return level21;
      case 22:
        return level22;
      case 23:
        return level23;
      case 24:
        return level24;
      case 25:
        return level25;
      case 26:
        return level26;
      case 27:
        return level27;
      case 28:
        return level28;
      case 29:
        return level29;
      case 30:
        return level30;
      case 31:
        return level31;
      case 32:
        return level32;
      case 33:
        return level33;
      case 34:
        return level34;
      case 35:
        return level35;
      case 36:
        return level36;
      case 37:
        return level37;
      case 38:
        return level38;
      case 39:
        return level39;
      case 40:
        return level40;
      case 41:
        return level41;
      case 42:
        return level42;
      case 43:
        return level43;
      case 44:
        return level44;
      case 45:
        return level45;
      case 46:
        return level46;
      case 47:
        return level47;
      case 48:
        return level48;
      case 49:
        return level49;
      case 50:
        return level50;
      default:
        return PrototypeLevels.level1;
    }
  }

  // --- SECTOR 2 EXTENDED LEVELS (7 - 10) ---

  /// Level 7: 3 colors, 5 tubes (3 full, 2 empty)
  static BallSortBoard get level7 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.green, BallType.red, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.yellow, BallType.yellow, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.yellow, BallType.green, BallType.red],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 8: 4 colors, 6 tubes (4 full, 2 empty)
  static BallSortBoard get level8 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.blue, BallType.green, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.green, BallType.yellow, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.yellow, BallType.red, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.red, BallType.blue, BallType.green],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 9: 4 colors, 6 tubes (4 full, 2 empty)
  static BallSortBoard get level9 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.red, BallType.blue, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.purple, BallType.green, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.red, BallType.purple, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.blue, BallType.red, BallType.purple],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 10: 4 colors, 6 tubes (4 full, 2 empty)
  static BallSortBoard get level10 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.blue, BallType.yellow, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [
        BallType.yellow,
        BallType.purple,
        BallType.green,
        BallType.purple,
      ],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.yellow, BallType.purple, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.green, BallType.yellow, BallType.blue],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 3: ADVANCED PLASMA ROUTING (11 - 15) ---

  /// Level 11: 5 colors, 7 tubes (5 full, 2 empty)
  static BallSortBoard get level11 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.green, BallType.purple, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.red, BallType.green, BallType.purple],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.yellow, BallType.red, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.blue, BallType.yellow, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.purple, BallType.blue, BallType.yellow],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 12: 5 colors, 7 tubes (5 full, 2 empty)
  static BallSortBoard get level12 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.red, BallType.yellow, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.blue, BallType.red, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.purple, BallType.blue, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.green, BallType.purple, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.yellow, BallType.green, BallType.purple],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 13: 5 colors, 7 tubes (5 full, 2 empty)
  static BallSortBoard get level13 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.red, BallType.blue, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [
        BallType.purple,
        BallType.yellow,
        BallType.green,
        BallType.purple,
      ],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.yellow, BallType.red, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [
        BallType.green,
        BallType.purple,
        BallType.yellow,
        BallType.yellow,
      ],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.green, BallType.red, BallType.blue],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 14: 5 colors, 8 tubes (5 full, 3 empty helper tubes)
  static BallSortBoard get level14 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.purple, BallType.red, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.yellow, BallType.purple, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.green, BallType.yellow, BallType.purple],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.blue, BallType.green, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.red, BallType.blue, BallType.green],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 15: 5 colors, 7 tubes (5 full, 2 empty)
  static BallSortBoard get level15 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.blue, BallType.red, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.purple, BallType.blue, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.yellow, BallType.purple, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.green, BallType.yellow, BallType.purple],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.red, BallType.green, BallType.yellow],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 4: MASTER QUANTUM ISOLATION (16 - 20) ---

  /// Level 16: 5 colors, 7 tubes (5 full, 2 empty)
  static BallSortBoard get level16 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.yellow, BallType.blue, BallType.purple],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.red, BallType.yellow, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.green, BallType.red, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.purple, BallType.green, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.blue, BallType.purple, BallType.green],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 17: 5 colors, 8 tubes (5 full, 3 empty helper tubes)
  static BallSortBoard get level17 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.blue, BallType.yellow, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.green, BallType.blue, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.purple, BallType.green, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.red, BallType.purple, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.yellow, BallType.red, BallType.purple],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 18: 5 colors, 7 tubes (5 full, 2 empty)
  static BallSortBoard get level18 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.green, BallType.red, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.blue, BallType.green, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.purple, BallType.blue, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.yellow, BallType.purple, BallType.blue],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.red, BallType.yellow, BallType.purple],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 19: 5 colors, 8 tubes (5 full, 3 empty)
  static BallSortBoard get level19 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.red, BallType.purple, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.yellow, BallType.red, BallType.purple],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.blue, BallType.yellow, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.green, BallType.blue, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.purple, BallType.green, BallType.blue],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 20: Pinnacle Sector Final Boss (5 colors, 7 tubes, 2 empty)
  static BallSortBoard get level20 => BallSortBoard([
    Tube(
      capacity: 4,
      balls: [BallType.purple, BallType.green, BallType.yellow, BallType.red],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.blue, BallType.purple, BallType.green, BallType.yellow],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.red, BallType.blue, BallType.purple, BallType.green],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.yellow, BallType.red, BallType.blue, BallType.purple],
    ),
    Tube(
      capacity: 4,
      balls: [BallType.green, BallType.yellow, BallType.red, BallType.blue],
    ),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 5: ENTROPY CALIBRATION (LEVELS 21 - 25) ---

  /// Level 21: 4 colors, 6 tubes (2 empty)
  /// Tier: Sector 5 (Entry) | Optimal moves: 12 | Frag: 0.83
  /// Intent: Post-Sector 4 warm-up; clean 4-color routing with balanced branch points.
  /// Seed: 20263851 | Canonical Hash: 0,0,1,2|0,2,3,2|1,3,3,2|3,1,0,1|E|E
  static BallSortBoard get level21 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.green, BallType.green, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.red, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.red, BallType.blue, BallType.green, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 22: 4 colors, 5 tubes (1 empty)
  /// Tier: Sector 5 (Constraint) | Optimal moves: 11 | Frag: 0.83
  /// Intent: Single empty chamber challenge; tests spatial planning with restricted buffers.
  /// Seed: 20263982 | Canonical Hash: 0,1,1,2|1,3,2,0|2,0,3,3|2,1,0,3|E
  static BallSortBoard get level22 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.red, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.green, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.red, BallType.red]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.green, BallType.blue, BallType.red]),
    Tube(capacity: 4),
  ]);

  /// Level 23: 5 colors, 8 tubes (3 empty)
  /// Tier: Sector 5 (Recovery) | Optimal moves: 14 | Frag: 0.80
  /// Intent: Breather recovery puzzle; 3 helper tubes allow open plasma transfer experiments.
  /// Seed: 20264113 | Canonical Hash: 0,0,1,2|1,0,2,3|1,3,4,0|4,1,2,2|4,3,3,4|E|E|E
  static BallSortBoard get level23 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.green, BallType.red, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.blue, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.red, BallType.blue, BallType.yellow, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.purple, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.red, BallType.green, BallType.purple, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 24: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 5 (Escalation) | Optimal moves: 15 | Frag: 0.87
  /// Intent: Classic 5-color escalation; high color mixing requiring multi-stage sorting.
  /// Seed: 20264244 | Canonical Hash: 0,0,1,2|0,1,3,1|1,2,3,4|4,2,3,2|4,4,0,3|E|E
  static BallSortBoard get level24 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.purple, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.purple, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.blue, BallType.green, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.green, BallType.green, BallType.yellow, BallType.red]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.red, BallType.purple, BallType.red]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 25: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 5 (Boss) | Optimal moves: 16 | Frag: 0.93
  /// Intent: Sector 5 Climax: high fragmentation with deceptive early moves.
  /// Seed: 20264375 | Canonical Hash: 0,0,1,2|1,2,3,0|3,2,1,4|4,1,2,3|4,3,0,4|E|E
  static BallSortBoard get level25 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.green, BallType.purple, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.purple, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.yellow, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.red, BallType.green, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.green, BallType.red, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 6: RESONANCE FLUX (LEVELS 26 - 30) ---

  /// Level 26: 4 colors, 6 tubes (2 empty)
  /// Tier: Sector 6 (Breather) | Optimal moves: 12 | Frag: 0.92
  /// Intent: Post-boss breather; 4 colors provide quick satisfying feedback.
  /// Seed: 20264506 | Canonical Hash: 0,0,1,2|1,0,1,3|2,1,0,3|2,3,2,3|E|E
  static BallSortBoard get level26 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.red, BallType.green, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.blue, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.red, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.green, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 27: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 6 (Core) | Optimal moves: 15 | Frag: 0.87
  /// Intent: Interleaved color stacks where key transfer targets are buried at depth 1.
  /// Seed: 20264637 | Canonical Hash: 0,0,1,0|2,1,0,3|2,3,4,1|3,1,4,4|3,2,4,2|E|E
  static BallSortBoard get level27 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.red, BallType.red]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.green, BallType.purple, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.purple, BallType.green, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.red, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.red, BallType.green]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 28: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 6 (Core) | Optimal moves: 15 | Frag: 0.93
  /// Intent: Symmetric branching with enticing false-lead moves.
  /// Seed: 20264768 | Canonical Hash: 0,1,1,2|0,3,1,3|1,2,4,0|2,4,0,3|4,3,2,4|E|E
  static BallSortBoard get level28 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.blue, BallType.purple, BallType.green, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.red, BallType.purple, BallType.yellow, BallType.red]),
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.red, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.blue, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.green, BallType.yellow]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 29: 4 colors, 5 tubes (1 empty)
  /// Tier: Sector 6 (Constraint) | Optimal moves: 12 | Frag: 0.92
  /// Intent: High-tension 1-helper bottleneck requiring strict move sequencing.
  /// Seed: 20264899 | Canonical Hash: 0,1,1,2|0,3,2,0|1,3,2,3|3,0,1,2|E
  static BallSortBoard get level29 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.green, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.green, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.red, BallType.red, BallType.green]),
    Tube(capacity: 4),
  ]);

  /// Level 30: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 6 (Boss) | Optimal moves: 17 | Frag: 1.00
  /// Intent: Mid-campaign milestone boss; maximum entropy and deep color interdependence.
  /// Seed: 20265030 | Canonical Hash: 0,1,0,2|0,3,2,0|2,1,3,4|2,3,4,1|4,1,3,4|E|E
  static BallSortBoard get level30 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.purple, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.purple, BallType.green, BallType.red]),
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.blue, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.purple, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.red, BallType.green]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 7: SUBATOMIC SYNTHESIS (LEVELS 31 - 35) ---

  /// Level 31: 4 colors, 6 tubes (2 empty)
  /// Tier: Sector 7 (Breather) | Optimal moves: 13 | Frag: 0.92
  /// Intent: Palette cleanser post-milestone; straightforward grouped-transfer combos.
  /// Seed: 20265161 | Canonical Hash: 0,0,1,2|0,1,2,3|1,2,0,3|3,2,1,3|E|E
  static BallSortBoard get level31 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.blue, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.green, BallType.blue, BallType.yellow, BallType.green]),
    Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.yellow, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 32: 5 colors, 8 tubes (3 empty)
  /// Tier: Sector 7 (Sprawl) | Optimal moves: 15 | Frag: 0.87
  /// Intent: Sprawling 8-chamber routing; gives players ample temporary holding slots.
  /// Seed: 20265292 | Canonical Hash: 0,1,0,2|1,2,3,4|3,4,1,2|4,1,0,0|4,3,3,2|E|E|E
  static BallSortBoard get level32 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.red, BallType.green, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.red, BallType.blue, BallType.purple, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.purple, BallType.purple, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.yellow, BallType.red, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.green, BallType.green]),
    Tube(capacity: 4),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 33: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 7 (Core) | Optimal moves: 16 | Frag: 0.93
  /// Intent: Triple color block entanglement; requires unearthing foundation balls early.
  /// Seed: 20265423 | Canonical Hash: 0,1,0,2|0,3,2,0|1,4,4,1|2,3,4,3|4,3,2,1|E|E
  static BallSortBoard get level33 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.red, BallType.yellow, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.purple, BallType.red]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.red, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.blue, BallType.green, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.purple, BallType.purple, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 34: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 7 (Core) | Optimal moves: 16 | Frag: 0.93
  /// Intent: Complex cyclic color dependencies where premature consolidation blocks progress.
  /// Seed: 20265554 | Canonical Hash: 0,0,1,0|1,2,3,0|2,1,4,3|3,4,2,4|4,2,3,1|E|E
  static BallSortBoard get level34 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.purple, BallType.blue, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.purple, BallType.red]),
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.purple, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.blue, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.green, BallType.green, BallType.red, BallType.green]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 35: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 7 (Boss) | Optimal moves: 17 | Frag: 1.00
  /// Intent: Sector 7 Climax: deeply buried primary color roots requiring 17+ precise transfers.
  /// Seed: 20265685 | Canonical Hash: 0,1,2,0|1,3,0,4|3,0,2,4|3,1,4,2|4,1,2,3|E|E
  static BallSortBoard get level35 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.green, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.blue, BallType.green, BallType.red]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.yellow, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.purple, BallType.blue, BallType.red]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.green, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 8: MAGNETIC CHAMBERING (LEVELS 36 - 40) ---

  /// Level 36: 5 colors, 8 tubes (3 empty)
  /// Tier: Sector 8 (Breather) | Optimal moves: 14 | Frag: 0.87
  /// Intent: Expansive 3-helper layout to recover from Level 35 peak tension.
  /// Seed: 20265816 | Canonical Hash: 0,1,0,2|2,3,4,3|3,0,1,1|3,4,4,2|4,2,1,0|E|E|E
  static BallSortBoard get level36 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.purple, BallType.red, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.blue, BallType.yellow, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.blue, BallType.green]),
    Tube(capacity: 4, balls: [BallType.red, BallType.green, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.purple, BallType.red, BallType.purple]),
    Tube(capacity: 4),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 37: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 8 (Core) | Optimal moves: 16 | Frag: 0.87
  /// Intent: Layered color bands; requires peeling outer layers across both helper chambers.
  /// Seed: 20265947 | Canonical Hash: 0,1,1,2|0,3,1,2|0,3,4,4|2,3,4,0|4,1,2,3|E|E
  static BallSortBoard get level37 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.purple, BallType.yellow, BallType.blue, BallType.green]),
    Tube(capacity: 4, balls: [BallType.red, BallType.blue, BallType.green, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.yellow, BallType.red, BallType.red]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.blue, BallType.blue, BallType.green]),
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.red, BallType.purple]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 38: 4 colors, 5 tubes (1 empty)
  /// Tier: Sector 8 (Constraint) | Optimal moves: 12 | Frag: 0.92
  /// Intent: Precision 1-helper puzzle; zero margin for wasted intermediate transfers.
  /// Seed: 20266078 | Canonical Hash: 0,1,0,1|0,2,0,3|1,3,3,2|3,2,1,2|E
  static BallSortBoard get level38 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.red, BallType.blue, BallType.red]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.yellow, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.green, BallType.red]),
    Tube(capacity: 4),
  ]);

  /// Level 39: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 8 (Core) | Optimal moves: 16 | Frag: 0.87
  /// Intent: Twin-chamber color lock; two chambers share identical top/bottom alternating colors.
  /// Seed: 20266209 | Canonical Hash: 0,0,1,2|0,2,1,3|3,0,4,4|3,1,2,4|3,2,4,1|E|E
  static BallSortBoard get level39 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.blue, BallType.red, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.yellow, BallType.blue, BallType.red]),
    Tube(capacity: 4, balls: [BallType.green, BallType.red, BallType.purple, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.purple, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.blue, BallType.green]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 40: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 8 (Boss) | Optimal moves: 17 | Frag: 0.93
  /// Intent: Sector 8 Boss: high search complexity, multiple tantalizing dead-end branch paths.
  /// Seed: 20266340 | Canonical Hash: 0,1,0,2|0,1,3,3|0,3,4,2|2,1,4,1|2,4,3,4|E|E
  static BallSortBoard get level40 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.yellow, BallType.green, BallType.blue, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.green, BallType.yellow, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.green, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.red, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.red, BallType.blue, BallType.red]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 9: SUPERPOSITION ROUTING (LEVELS 41 - 45) ---

  /// Level 41: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 9 (Breather) | Optimal moves: 14 | Frag: 0.80
  /// Intent: Gentle ramp into the penultimate sector; smooth multi-ball transfers.
  /// Seed: 20266471 | Canonical Hash: 0,0,1,2|2,0,2,3|3,0,1,1|3,4,4,3|4,2,1,4|E|E
  static BallSortBoard get level41 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.blue, BallType.red, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.purple, BallType.yellow, BallType.red]),
    Tube(capacity: 4, balls: [BallType.green, BallType.blue, BallType.blue, BallType.green]),
    Tube(capacity: 4, balls: [BallType.red, BallType.purple, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.green, BallType.purple, BallType.yellow, BallType.yellow]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 42: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 9 (Core) | Optimal moves: 15 | Frag: 0.87
  /// Intent: Asymmetric distribution of color runs across tubes.
  /// Seed: 20266602 | Canonical Hash: 0,0,1,2|1,3,4,0|2,4,4,1|3,1,3,2|4,2,3,0|E|E
  static BallSortBoard get level42 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.purple, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.red, BallType.purple, BallType.purple, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.red, BallType.green, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.yellow, BallType.blue, BallType.red]),
    Tube(capacity: 4, balls: [BallType.green, BallType.blue, BallType.green, BallType.red]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 43: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 9 (Core) | Optimal moves: 17 | Frag: 1.00
  /// Intent: Deep trap layout; one obvious initial move irreversibly deadlocks the board.
  /// Seed: 20266733 | Canonical Hash: 0,1,2,0|1,2,3,4|1,3,4,0|2,4,3,2|4,3,1,0|E|E
  static BallSortBoard get level43 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.yellow, BallType.purple, BallType.green, BallType.red]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.purple, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.purple, BallType.green]),
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.blue, BallType.red]),
    Tube(capacity: 4, balls: [BallType.green, BallType.purple, BallType.yellow, BallType.red]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 44: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 9 (Core) | Optimal moves: 17 | Frag: 0.93
  /// Intent: Near-maximum entropy requiring full utilization of both helper chambers in tandem.
  /// Seed: 20266864 | Canonical Hash: 0,1,2,0|1,2,0,1|3,1,0,4|3,4,2,4|4,2,3,3|E|E
  static BallSortBoard get level44 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.green, BallType.red, BallType.purple, BallType.red]),
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.blue, BallType.red]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.purple, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.purple, BallType.blue, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.red, BallType.purple, BallType.green, BallType.green]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 45: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 9 (Boss) | Optimal moves: 18 | Frag: 1.00
  /// Intent: Penultimate sector climax; 18+ moves requiring long-range lookahead.
  /// Seed: 20266995 | Canonical Hash: 0,1,0,1|0,2,3,1|0,4,2,4|3,4,1,2|3,4,3,2|E|E
  static BallSortBoard get level45 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.purple, BallType.green, BallType.purple, BallType.green]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.blue, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.red, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.yellow, BallType.blue, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.green, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  // --- SECTOR 10: SINGULARITY ISOLATION (LEVELS 46 - 50) ---

  /// Level 46: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 10 (Entry) | Optimal moves: 15 | Frag: 0.87
  /// Intent: Grandmaster tier entry; clean, aesthetic distribution with rich transfer lines.
  /// Seed: 20267126 | Canonical Hash: 0,1,0,2|0,3,4,4|3,1,2,3|4,0,2,2|4,1,3,1|E|E
  static BallSortBoard get level46 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.red, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.yellow, BallType.green, BallType.red]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.yellow, BallType.blue, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.green, BallType.blue, BallType.purple, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.green, BallType.red, BallType.red]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 47: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 10 (Master) | Optimal moves: 16 | Frag: 0.93
  /// Intent: Complex color interleaving where each color is split across 4 distinct chambers.
  /// Seed: 20267257 | Canonical Hash: 0,1,1,0|1,2,0,3|3,4,2,4|4,2,3,2|4,3,0,1|E|E
  static BallSortBoard get level47 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.green, BallType.purple, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.purple, BallType.red]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.red, BallType.red, BallType.purple]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.green, BallType.yellow, BallType.green]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.blue, BallType.green, BallType.blue]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 48: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 10 (Master) | Optimal moves: 18 | Frag: 1.00
  /// Intent: Extreme multi-stage unraveling; requires 3 intermediate color swaps.
  /// Seed: 20267388 | Canonical Hash: 0,1,0,2|2,1,3,4|2,3,4,0|3,2,1,4|3,4,1,0|E|E
  static BallSortBoard get level48 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.red, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.blue, BallType.yellow, BallType.green]),
    Tube(capacity: 4, balls: [BallType.purple, BallType.green, BallType.yellow, BallType.red]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.purple, BallType.green, BallType.red]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.purple, BallType.green]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 49: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 10 (Semi-Final) | Optimal moves: 18 | Frag: 1.00
  /// Intent: Master puzzle; highest recorded human decision complexity with multiple trap cycles.
  /// Seed: 20267519 | Canonical Hash: 0,1,0,2|1,0,3,1|2,3,0,4|2,3,4,3|2,4,1,4|E|E
  static BallSortBoard get level49 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.red, BallType.yellow, BallType.red, BallType.green]),
    Tube(capacity: 4, balls: [BallType.green, BallType.blue, BallType.yellow, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.red, BallType.purple, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.green, BallType.purple, BallType.red, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.green, BallType.purple, BallType.blue, BallType.purple]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);

  /// Level 50: 5 colors, 7 tubes (2 empty)
  /// Tier: Sector 10 (Grand Finale) | Optimal moves: 18 | Frag: 1.00
  /// Intent: The Pinnacle Grand Finale: 98th-percentile move length (18 moves), near-maximal fragmentation, unique non-isomorphic topology.
  /// Seed: 20267650 | Canonical Hash: 0,1,2,0|0,3,1,4|1,2,3,4|4,3,2,0|4,3,2,1|E|E
  static BallSortBoard get level50 => BallSortBoard([
    Tube(capacity: 4, balls: [BallType.blue, BallType.yellow, BallType.green, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.red, BallType.purple, BallType.green, BallType.blue]),
    Tube(capacity: 4, balls: [BallType.red, BallType.purple, BallType.green, BallType.yellow]),
    Tube(capacity: 4, balls: [BallType.blue, BallType.purple, BallType.yellow, BallType.red]),
    Tube(capacity: 4, balls: [BallType.yellow, BallType.green, BallType.purple, BallType.red]),
    Tube(capacity: 4),
    Tube(capacity: 4),
  ]);


}
