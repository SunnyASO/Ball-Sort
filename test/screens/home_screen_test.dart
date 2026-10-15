import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ball_sort/screens/game_screen.dart';
import 'package:ball_sort/screens/home_screen.dart';
import 'package:ball_sort/screens/level_map_screen.dart';
import 'package:ball_sort/screens/shop_screen.dart';
import 'package:ball_sort/services/progression_service.dart';

void main() {
  group('HomeScreen & Navigation Flow Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'highestUnlockedLevel': 12,
        'currentLevel': 12,
        'stars_level_1': 3,
        'stars_level_2': 3,
        'stars_level_3': 2,
      });
      await ProgressionService.instance.initialize();
    });

    testWidgets('renders brand title, mission card, and action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      // Verify branding and status
      expect(find.text('ORB LAB'), findsOneWidget);
      expect(find.text('QUANTUM SORT SIMULATOR'), findsOneWidget);
      expect(find.text('LAB ONLINE'), findsOneWidget);

      // Verify stars count (3 + 3 + 2 = 8 stars)
      expect(find.text('8 / 150'), findsOneWidget);

      // Verify mission card
      expect(find.byKey(const Key('home_mission_card')), findsOneWidget);
      expect(find.text('CURRENT ASSIGNMENT'), findsOneWidget);
      expect(find.text('SECTOR 12'), findsWidgets);
      expect(find.text('Sectors Unlocked: 12 / 50'), findsOneWidget);

      // Verify action buttons
      expect(find.byKey(const Key('continue_mission_button')), findsOneWidget);
      expect(find.byKey(const Key('sectors_map_button')), findsOneWidget);
      expect(find.byKey(const Key('wardrobe_button')), findsOneWidget);
      expect(find.byKey(const Key('home_core_orb')), findsOneWidget);
    });

    testWidgets('continue mission navigates directly to active saved level', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      // Tap CONTINUE MISSION
      await tester.tap(find.byKey(const Key('continue_mission_button')));
      await tester.pumpAndSettle();

      // Should be in GameScreen for Level 12
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.text('Level 12'), findsOneWidget);
      expect(find.text('SEC 12'), findsOneWidget);
    });

    testWidgets('sectors button navigates to LevelMapScreen and back pops to HomeScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      // Tap SECTORS
      await tester.tap(find.byKey(const Key('sectors_map_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LevelMapScreen), findsOneWidget);
      expect(find.text('Quantum Sectors'), findsOneWidget);

      // Tap Back on LevelMapScreen
      expect(find.byKey(const Key('map_back_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('map_back_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should return to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('ORB LAB'), findsOneWidget);
    });

    testWidgets('research button navigates to ShopScreen and back pops to HomeScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      // Tap RESEARCH / SHOP
      await tester.tap(find.byKey(const Key('wardrobe_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ShopScreen), findsOneWidget);

      // Tap Back on ShopScreen
      expect(find.byKey(const Key('shop_back_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('shop_back_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should return to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('header home button pops back to HomeScreen if no moves made', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      await tester.tap(find.byKey(const Key('continue_mission_button')));
      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsOneWidget);

      // Tap top-left header home button
      expect(find.byKey(const Key('header_home_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('header_home_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Immediately returns to HomeScreen since moveCount == 0
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('header home button displays pause modal when moves have been made', (
      WidgetTester tester,
    ) async {
      // Set to Level 1 where Tube 0 -> Tube 2 is a valid move
      await ProgressionService.instance.setCurrentLevel(1);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      await tester.tap(find.byKey(const Key('continue_mission_button')));
      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsOneWidget);

      // Perform a move: 0 -> 2
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 1'), findsOneWidget);

      // Tap header home button
      await tester.tap(find.byKey(const Key('header_home_button')));
      await tester.pumpAndSettle();

      // Pause modal must be displayed
      expect(find.text('MISSION PAUSED'), findsOneWidget);
      expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
      expect(find.byKey(const Key('pause_restart_button')), findsOneWidget);
      expect(find.byKey(const Key('pause_exit_button')), findsOneWidget);

      // Tap RESUME MISSION
      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pumpAndSettle();

      // Still in GameScreen and move preserved
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.text('Moves: 1'), findsOneWidget);

      // Tap header home button again and tap EXIT TO HEADQUARTERS
      await tester.tap(find.byKey(const Key('header_home_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pause_exit_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Now back in HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
