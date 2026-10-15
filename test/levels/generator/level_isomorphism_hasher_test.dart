import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/levels/generator/level_isomorphism_hasher.dart';
import 'package:ball_sort/levels/level_catalog.dart';
import 'package:ball_sort/levels/prototype_levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelIsomorphismHasher Unit Tests', () {
    const hasher = LevelIsomorphismHasher();

    test('identical boards produce identical canonical hashes', () {
      final b1 = PrototypeLevels.level1;
      final b2 = PrototypeLevels.level1;

      expect(hasher.canonicalHash(b1), equals(hasher.canonicalHash(b2)));
      expect(hasher.areIsomorphic(b1, b2), isTrue);
    });

    test('permutation of chamber order produces identical canonical hash', () {
      // Reorder tubes: [tube1, tube0, tube3, tube2]
      final bOriginal = PrototypeLevels.level1;
      final bPermuted = BallSortBoard([
        bOriginal.tubes[1],
        bOriginal.tubes[0],
        bOriginal.tubes[3],
        bOriginal.tubes[2],
      ]);

      expect(hasher.canonicalHash(bOriginal), equals(hasher.canonicalHash(bPermuted)));
      expect(hasher.areIsomorphic(bOriginal, bPermuted), isTrue);
    });

    test('renaming or permutation of ball colors produces identical canonical hash', () {
      // Swap Red <-> Blue in Level 1
      final bOriginal = PrototypeLevels.level1;
      final bRenamed = BallSortBoard(bOriginal.tubes.map((t) {
        return t.copyWith(balls: t.balls.map((b) {
          if (b == BallType.red) return BallType.blue;
          if (b == BallType.blue) return BallType.red;
          return b;
        }).toList());
      }).toList());

      expect(hasher.canonicalHash(bOriginal), equals(hasher.canonicalHash(bRenamed)));
      expect(hasher.areIsomorphic(bOriginal, bRenamed), isTrue);
    });

    test('simultaneous chamber permutation and color renaming produces identical canonical hash', () {
      // Swap colors AND reverse tubes
      final bOriginal = PrototypeLevels.level2; // 3 colors: red, blue, green
      final colorMap = {
        BallType.red: BallType.green,
        BallType.green: BallType.blue,
        BallType.blue: BallType.red,
      };

      final bTransformed = BallSortBoard(bOriginal.tubes.reversed.map((t) {
        return t.copyWith(balls: t.balls.map((b) => colorMap[b] ?? b).toList());
      }).toList());

      expect(hasher.canonicalHash(bOriginal), equals(hasher.canonicalHash(bTransformed)));
      expect(hasher.areIsomorphic(bOriginal, bTransformed), isTrue);
    });

    test('distinct non-isomorphic boards produce distinct canonical hashes', () {
      final b1 = PrototypeLevels.level1; // 2 colors
      final b2 = PrototypeLevels.level2; // 3 colors
      final b4 = PrototypeLevels.level4; // 4 colors

      expect(hasher.canonicalHash(b1), isNot(equals(hasher.canonicalHash(b2))));
      expect(hasher.canonicalHash(b2), isNot(equals(hasher.canonicalHash(b4))));
      expect(hasher.areIsomorphic(b1, b2), isFalse);
    });

    test('confirms Milestone 2A catalog duplicate discoveries', () {
      // Level 17 and Level 19 are identical tube permutations:
      final l17 = LevelCatalog.level17;
      final l19 = LevelCatalog.level19;
      expect(hasher.canonicalHash(l17), equals(hasher.canonicalHash(l19)));
      expect(hasher.areIsomorphic(l17, l19), isTrue);

      // Level 11, 12, 15, 16, 18, 20 are all isomorphic cyclic shifts:
      final l11 = LevelCatalog.level11;
      final l12 = LevelCatalog.level12;
      final l15 = LevelCatalog.level15;
      final l16 = LevelCatalog.level16;
      final l18 = LevelCatalog.level18;
      final l20 = LevelCatalog.level20;

      final hash11 = hasher.canonicalHash(l11);
      expect(hasher.canonicalHash(l12), equals(hash11));
      expect(hasher.canonicalHash(l15), equals(hash11));
      expect(hasher.canonicalHash(l16), equals(hash11));
      expect(hasher.canonicalHash(l18), equals(hash11));
      expect(hasher.canonicalHash(l20), equals(hash11));
    });
  });
}
