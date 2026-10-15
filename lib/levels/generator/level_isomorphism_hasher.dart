import '../../game/ball_sort_board.dart';
import '../../game/ball_type.dart';

/// Computes a canonical isomorphism signature for a [BallSortBoard].
///
/// Puzzles are considered structurally equivalent (isomorphic) if one can be transformed
/// into the other via:
/// 1. Permutation of chamber positions (reordering tubes).
/// 2. Renaming or permutation of ball colors.
/// 3. Any combination of both transformations.
///
/// For up to 5 colors ($5! = 120$ permutations), this hasher computes the lexicographical
/// minimum signature across all color permutations with tube-sorted canonical strings.
class LevelIsomorphismHasher {
  const LevelIsomorphismHasher();

  /// Computes the unique canonical isomorphism hash for [board].
  ///
  /// Guarantees that `canonicalHash(A) == canonicalHash(B)` if and only if
  /// board A and board B are isomorphic under chamber reordering and color permutation.
  String canonicalHash(BallSortBoard board) {
    final colors = <BallType>{};
    for (final tube in board.tubes) {
      for (final ball in tube.balls) {
        colors.add(ball);
      }
    }

    if (colors.isEmpty) {
      return List.filled(board.tubeCount, 'E').join('|');
    }

    final colorList = colors.toList()..sort((a, b) => a.index.compareTo(b.index));
    final perms = _permutations(colorList);

    String? minSignature;

    for (final perm in perms) {
      // Mapping: colorList[i] -> perm[i]
      final colorMap = <BallType, int>{};
      for (int i = 0; i < colorList.length; i++) {
        colorMap[colorList[i]] = perm[i].index;
      }

      final tubeStrings = board.tubes.map((tube) {
        if (tube.isEmpty) return 'E';
        return tube.balls.map((b) => colorMap[b]!).join(',');
      }).toList();

      // Sort tube strings alphabetically to ensure chamber-order invariance
      tubeStrings.sort();
      final signature = tubeStrings.join('|');

      if (minSignature == null || signature.compareTo(minSignature) < 0) {
        minSignature = signature;
      }
    }

    return minSignature!;
  }

  /// Checks whether two boards are structurally isomorphic under chamber and/or color permutations.
  bool areIsomorphic(BallSortBoard boardA, BallSortBoard boardB) {
    if (boardA.tubeCount != boardB.tubeCount) return false;
    if (boardA.totalBallCount != boardB.totalBallCount) return false;
    return canonicalHash(boardA) == canonicalHash(boardB);
  }

  /// Fast canonical key that sorts tubes alphabetically without color permutation.
  /// Matches [BoardSolver.canonicalKey].
  static String fastCanonicalKey(BallSortBoard board) {
    final tubeStrings = board.tubes.map((t) {
      if (t.isEmpty) return 'E';
      return t.balls.map((b) => b.index).join(',');
    }).toList();

    tubeStrings.sort();
    return tubeStrings.join('|');
  }

  List<List<T>> _permutations<T>(List<T> list) {
    if (list.length <= 1) return [list];
    final result = <List<T>>[];
    for (int i = 0; i < list.length; i++) {
      final elem = list[i];
      final remaining = List<T>.from(list)..removeAt(i);
      for (final p in _permutations(remaining)) {
        result.add([elem, ...p]);
      }
    }
    return result;
  }
}
