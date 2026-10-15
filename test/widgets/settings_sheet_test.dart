import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ball_sort/screens/game_screen.dart';
import 'package:ball_sort/screens/home_screen.dart';
import 'package:ball_sort/services/audio_haptic_service.dart';
import 'package:ball_sort/services/progression_service.dart';
import 'package:ball_sort/widgets/settings_sheet.dart';

void main() {
  group('SettingsSheet & Player Preferences Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'soundEnabled': true,
        'hapticsEnabled': true,
      });
      await ProgressionService.instance.initialize();
    });

    testWidgets('renders all settings sections, switches, and system specs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsSheet()),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('LAB SETTINGS'), findsOneWidget);
      expect(find.text('PREFERENCES & CALIBRATION'), findsOneWidget);
      expect(find.byKey(const Key('settings_close_button')), findsOneWidget);

      // Section 1: Sensory Controls
      expect(find.text('SENSORY FEEDBACK'), findsOneWidget);
      expect(find.byKey(const Key('sound_toggle_switch')), findsOneWidget);
      expect(find.byKey(const Key('haptic_toggle_switch')), findsOneWidget);
      expect(find.text('Auditory Clicks (Sound FX)'), findsOneWidget);
      expect(find.text('Haptic Feedback (Vibration)'), findsOneWidget);

      // Section 2: Vision & Accessibility
      expect(find.text('VISION & ACCESSIBILITY'), findsOneWidget);
      expect(find.text('Color-Blind Glyphs'), findsOneWidget);
      expect(find.text('PLANNED: M3D'), findsOneWidget);

      // Section 3: System Information
      expect(find.text('ABOUT ORB LAB'), findsOneWidget);
      expect(find.text('Orb Lab: Quantum Sort'), findsOneWidget);
      expect(find.text('1.0.0+1'), findsOneWidget);
      expect(find.text('50 Solver-Verified Sectors'), findsOneWidget);
    });

    testWidgets('toggling sound effects updates ProgressionService and AudioHapticService', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsSheet()),
        ),
      );
      await tester.pump();

      expect(ProgressionService.instance.soundEnabled, isTrue);
      expect(AudioHapticService.instance.soundEnabled, isTrue);

      // Toggle sound off
      await tester.tap(find.byKey(const Key('sound_toggle_switch')));
      await tester.pump();

      expect(ProgressionService.instance.soundEnabled, isFalse);
      expect(AudioHapticService.instance.soundEnabled, isFalse);

      // Toggle sound back on
      await tester.tap(find.byKey(const Key('sound_toggle_switch')));
      await tester.pump();

      expect(ProgressionService.instance.soundEnabled, isTrue);
      expect(AudioHapticService.instance.soundEnabled, isTrue);
    });

    testWidgets('toggling haptics updates ProgressionService and AudioHapticService', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsSheet()),
        ),
      );
      await tester.pump();

      expect(ProgressionService.instance.hapticsEnabled, isTrue);
      expect(AudioHapticService.instance.hapticsEnabled, isTrue);

      // Toggle haptics off
      await tester.tap(find.byKey(const Key('haptic_toggle_switch')));
      await tester.pump();

      expect(ProgressionService.instance.hapticsEnabled, isFalse);
      expect(AudioHapticService.instance.hapticsEnabled, isFalse);

      // Toggle haptics back on
      await tester.tap(find.byKey(const Key('haptic_toggle_switch')));
      await tester.pump();

      expect(ProgressionService.instance.hapticsEnabled, isTrue);
      expect(AudioHapticService.instance.hapticsEnabled, isTrue);
    });

    testWidgets('settings sheet opens from HomeScreen and closes via close button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      // Open settings from top status bar button
      expect(find.byKey(const Key('home_settings_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('home_settings_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SettingsSheet), findsOneWidget);
      expect(find.text('LAB SETTINGS'), findsOneWidget);

      // Close settings
      await tester.tap(find.byKey(const Key('settings_close_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SettingsSheet), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('settings sheet opens from GameScreen pause menu and persists values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen(initialLevelNumber: 1)));
      await tester.pumpAndSettle();

      // Make a move: 0 -> 2
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pumpAndSettle();

      // Open pause menu via header home/back button
      await tester.tap(find.byKey(const Key('header_home_button')));
      await tester.pumpAndSettle();

      expect(find.text('MISSION PAUSED'), findsOneWidget);

      // Open settings from pause menu
      expect(find.byKey(const Key('pause_settings_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('pause_settings_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsSheet), findsOneWidget);

      // Disable sound in in-game settings
      await tester.tap(find.byKey(const Key('sound_toggle_switch')));
      await tester.pump();
      expect(ProgressionService.instance.soundEnabled, isFalse);

      // Close settings sheet
      await tester.tap(find.byKey(const Key('settings_close_button')));
      await tester.pumpAndSettle();

      // Still in pause menu
      expect(find.text('MISSION PAUSED'), findsOneWidget);

      // Resume mission
      await tester.tap(find.byKey(const Key('pause_resume_button')));
      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(ProgressionService.instance.soundEnabled, isFalse);
    });
  });
}
