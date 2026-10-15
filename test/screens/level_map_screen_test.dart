import 'package:ball_sort/levels/level_catalog.dart';
import 'package:ball_sort/screens/level_map_screen.dart';
import 'package:ball_sort/services/progression_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LevelMapScreen 50-Level & 10-Sector Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'highestUnlockedLevel': 21,
        'currentLevel': 21,
        'stars_level_1': 3,
        'stars_level_20': 3,
      });
      await ProgressionService.instance.initialize();
    });

    testWidgets('renders progression header with 50 total levels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: LevelMapScreen(currentLevel: 21)),
      );
      await tester.pumpAndSettle();

      expect(find.text('ORB LAB'), findsOneWidget);
      expect(find.text('Quantum Sectors'), findsOneWidget);
      expect(find.text('20 / 50 Levels'), findsOneWidget);
      expect(find.text('PLAY LEVEL 21'), findsOneWidget);
    });

    testWidgets('renders all 10 sector titles and banners in the map trail', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: LevelMapScreen(currentLevel: 1)),
      );
      await tester.pumpAndSettle();

      const expectedSectors = [
        'Training Protocols',
        'Intermediate Containment',
        'Advanced Plasma Routing',
        'Quantum Isolation',
        'Entropy Calibration',
        'Resonance Flux',
        'Subatomic Synthesis',
        'Magnetic Chambering',
        'Superposition Routing',
        'Singularity Isolation',
      ];

      for (int i = 1; i <= 10; i++) {
        expect(
          find.text('SECTOR $i'),
          findsOneWidget,
          reason: 'Sector banner $i should exist in the trail',
        );
        expect(
          find.text(expectedSectors[i - 1]),
          findsOneWidget,
          reason: 'Sector title "${expectedSectors[i - 1]}" should exist',
        );
      }
    });

    testWidgets('contains all 50 level nodes in the widget tree', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: LevelMapScreen(currentLevel: 1)),
      );
      await tester.pumpAndSettle();

      expect(LevelCatalog.totalLevels, equals(50));
      // Level 1 to 21 are unlocked (highestUnlockedLevel is 21), so they show their numbers
      for (int lvl = 1; lvl <= 21; lvl++) {
        expect(
          find.text('$lvl'),
          findsAtLeastNWidgets(1),
          reason: 'Unlocked level $lvl node text must exist in the map',
        );
      }

      // Levels 22 to 50 are locked, rendering 29 lock icons
      expect(find.byIcon(Icons.lock), findsNWidgets(29));
    });

    testWidgets('tapping unlocked node invokes callback; tapping locked node does not', (
      WidgetTester tester,
    ) async {
      int? selectedLevel;

      await tester.pumpWidget(
        MaterialApp(
          home: LevelMapScreen(
            currentLevel: 21,
            onSelectLevel: (lvl) {
              selectedLevel = lvl;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap unlocked level 1 (unlocked since highestUnlocked is 21)
      await tester.ensureVisible(find.text('1').first);
      await tester.tap(find.text('1').first);
      await tester.pump();
      expect(selectedLevel, equals(1));

      // Reset callback tracker
      selectedLevel = null;

      // Try tapping locked level (e.g. any locked node with Icons.lock)
      final lockFinder = find.byIcon(Icons.lock).first;
      await tester.ensureVisible(lockFinder);
      await tester.tap(lockFinder, warnIfMissed: false);
      await tester.pump();
      expect(selectedLevel, isNull);
    });

    testWidgets('sticky bottom bar selects the active level', (
      WidgetTester tester,
    ) async {
      int? selectedLevel;

      await tester.pumpWidget(
        MaterialApp(
          home: LevelMapScreen(
            currentLevel: 25,
            onSelectLevel: (lvl) {
              selectedLevel = lvl;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final playButton = find.text('PLAY LEVEL 25');
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      await tester.pump();
      expect(selectedLevel, equals(25));
    });
  });
}
