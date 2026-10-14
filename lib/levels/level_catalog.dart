import '../game/ball_sort_board.dart';
import '../game/ball_type.dart';
import '../game/tube.dart';
import 'prototype_levels.dart';

/// Comprehensive curated level catalog across all 4 Orb Lab Sectors (Levels 1 to 20).
///
/// Features:
/// - Sector 1: Training Protocols (Levels 1 - 5)
/// - Sector 2: Intermediate Containment (Levels 6 - 10)
/// - Sector 3: Advanced Plasma Routing (Levels 11 - 15)
/// - Sector 4: Master Quantum Isolation (Levels 16 - 20)
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
  static const int totalLevels = 20;

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
}
