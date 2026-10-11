import '../game/ball_sort_board.dart';
import '../game/ball_type.dart';
import '../game/tube.dart';

/// Provides prototype levels for the Ball Sort puzzle.
class PrototypeLevels {
  const PrototypeLevels._();

  /// Total number of prototype levels currently defined.
  static const int totalLevels = 6;

  /// Retrieves the board for [levelNumber] (1-indexed, 1..6).
  static BallSortBoard getLevel(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
      case 4:
        return level4;
      case 5:
        return level5;
      case 6:
        return level6;
      default:
        throw ArgumentError.value(
          levelNumber,
          'levelNumber',
          'Level must be between 1 and $totalLevels',
        );
    }
  }

  /// Level 1:
  /// - 2 colors: red, blue
  /// - Capacity: 4 balls per tube
  /// - 4 tubes total (2 filled, 2 empty)
  /// - Bottom-to-top (index 0 is bottom, index 3 is top):
  ///   Tube 0: [red, blue, red, blue]
  ///   Tube 1: [blue, red, blue, red]
  ///   Tube 2: []
  ///   Tube 3: []
  static BallSortBoard get level1 {
    return BallSortBoard([
      Tube(
        capacity: 4,
        balls: [BallType.red, BallType.blue, BallType.red, BallType.blue],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.blue, BallType.red, BallType.blue, BallType.red],
      ),
      Tube(capacity: 4),
      Tube(capacity: 4),
    ]);
  }

  /// Level 2:
  /// - 3 colors: red, blue, green
  /// - Capacity: 4
  /// - 5 tubes total (3 filled, 2 empty)
  /// - Bottom-to-top:
  ///   Tube 0: [red, green, blue, green]
  ///   Tube 1: [blue, red, green, blue]
  ///   Tube 2: [green, blue, red, red]
  ///   Tube 3: []
  ///   Tube 4: []
  static BallSortBoard get level2 {
    return BallSortBoard([
      Tube(
        capacity: 4,
        balls: [BallType.red, BallType.green, BallType.blue, BallType.green],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.blue, BallType.red, BallType.green, BallType.blue],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.green, BallType.blue, BallType.red, BallType.red],
      ),
      Tube(capacity: 4),
      Tube(capacity: 4),
    ]);
  }

  /// Level 3:
  /// - 3 colors: red, blue, green (increased fragmentation)
  /// - Capacity: 4
  /// - 5 tubes total (3 filled, 2 empty)
  /// - Bottom-to-top:
  ///   Tube 0: [blue, green, red, blue]
  ///   Tube 1: [green, red, blue, red]
  ///   Tube 2: [red, blue, green, green]
  ///   Tube 3: []
  ///   Tube 4: []
  static BallSortBoard get level3 {
    return BallSortBoard([
      Tube(
        capacity: 4,
        balls: [BallType.blue, BallType.green, BallType.red, BallType.blue],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.green, BallType.red, BallType.blue, BallType.red],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.red, BallType.blue, BallType.green, BallType.green],
      ),
      Tube(capacity: 4),
      Tube(capacity: 4),
    ]);
  }

  /// Level 4:
  /// - 4 colors: red, blue, green, yellow
  /// - Capacity: 4
  /// - 6 tubes total (4 filled, 2 empty)
  /// - Bottom-to-top:
  ///   Tube 0: [yellow, blue, red, green]
  ///   Tube 1: [red, yellow, green, blue]
  ///   Tube 2: [green, red, yellow, red]
  ///   Tube 3: [blue, green, blue, yellow]
  ///   Tube 4: []
  ///   Tube 5: []
  static BallSortBoard get level4 {
    return BallSortBoard([
      Tube(
        capacity: 4,
        balls: [BallType.yellow, BallType.blue, BallType.red, BallType.green],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.red, BallType.yellow, BallType.green, BallType.blue],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.green, BallType.red, BallType.yellow, BallType.red],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.blue, BallType.green, BallType.blue, BallType.yellow],
      ),
      Tube(capacity: 4),
      Tube(capacity: 4),
    ]);
  }

  /// Level 5:
  /// - 5 colors: red, blue, green, yellow, purple
  /// - Capacity: 4
  /// - 7 tubes total (5 filled, 2 empty)
  /// - Bottom-to-top:
  ///   Tube 0: [purple, red, green, blue]
  ///   Tube 1: [yellow, blue, purple, red]
  ///   Tube 2: [green, yellow, red, green]
  ///   Tube 3: [blue, purple, yellow, yellow]
  ///   Tube 4: [red, green, blue, purple]
  ///   Tube 5: []
  ///   Tube 6: []
  static BallSortBoard get level5 {
    return BallSortBoard([
      Tube(
        capacity: 4,
        balls: [BallType.purple, BallType.red, BallType.green, BallType.blue],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.yellow, BallType.blue, BallType.purple, BallType.red],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.green, BallType.yellow, BallType.red, BallType.green],
      ),
      Tube(
        capacity: 4,
        balls: [
          BallType.blue,
          BallType.purple,
          BallType.yellow,
          BallType.yellow,
        ],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.red, BallType.green, BallType.blue, BallType.purple],
      ),
      Tube(capacity: 4),
      Tube(capacity: 4),
    ]);
  }

  /// Level 6:
  /// - 5 colors: red, blue, green, yellow, purple (high entropy)
  /// - Capacity: 4
  /// - 7 tubes total (5 filled, 2 empty)
  /// - Bottom-to-top:
  ///   Tube 0: [red, green, yellow, blue]
  ///   Tube 1: [purple, red, blue, green]
  ///   Tube 2: [yellow, purple, red, yellow]
  ///   Tube 3: [green, blue, purple, red]
  ///   Tube 4: [blue, yellow, green, purple]
  ///   Tube 5: []
  ///   Tube 6: []
  static BallSortBoard get level6 {
    return BallSortBoard([
      Tube(
        capacity: 4,
        balls: [BallType.red, BallType.green, BallType.yellow, BallType.blue],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.purple, BallType.red, BallType.blue, BallType.green],
      ),
      Tube(
        capacity: 4,
        balls: [
          BallType.yellow,
          BallType.purple,
          BallType.red,
          BallType.yellow,
        ],
      ),
      Tube(
        capacity: 4,
        balls: [BallType.green, BallType.blue, BallType.purple, BallType.red],
      ),
      Tube(
        capacity: 4,
        balls: [
          BallType.blue,
          BallType.yellow,
          BallType.green,
          BallType.purple,
        ],
      ),
      Tube(capacity: 4),
      Tube(capacity: 4),
    ]);
  }
}
