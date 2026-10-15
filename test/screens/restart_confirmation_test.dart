import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ball_sort/screens/game_screen.dart';
import 'package:ball_sort/widgets/tube_widget.dart';

void main() {
  group('Safe Restart Confirmation Tests', () {
    testWidgets('restart with 0 moves restarts immediately without confirmation dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Moves: 0'), findsOneWidget);

      // Tap restart with 0 moves
      await tester.tap(find.byKey(const Key('restart_button')));
      await tester.pump();

      // No confirmation dialog shown
      expect(find.text('Restart this level?'), findsNothing);
      expect(find.text('Moves: 0'), findsOneWidget);
    });

    testWidgets('restart with moves > 0 displays confirmation dialog and cancel preserves state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      // Make a move: 0 -> 2
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 1'), findsOneWidget);

      // Tap restart
      await tester.tap(find.byKey(const Key('restart_button')));
      await tester.pumpAndSettle();

      // Confirmation dialog is shown
      expect(find.text('Restart this level?'), findsOneWidget);
      expect(find.textContaining('Sector 1 will be lost'), findsOneWidget);
      expect(find.byKey(const Key('restart_cancel_button')), findsOneWidget);
      expect(find.byKey(const Key('restart_confirm_button')), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.byKey(const Key('restart_cancel_button')));
      await tester.pumpAndSettle();

      // Board state is preserved: moves still 1, tube 2 has 1 ball
      expect(find.text('Moves: 1'), findsOneWidget);
      final tube2 = tester.widget<TubeWidget>(find.byKey(const ValueKey('tube_2')));
      expect(tube2.tube.balls.length, equals(1));
    });

    testWidgets('restart with moves > 0 confirmed resets moves and restores initial board', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      // Make a move: 0 -> 2
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 1'), findsOneWidget);

      // Tap restart and confirm
      await tester.tap(find.byKey(const Key('restart_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('restart_confirm_button')));
      await tester.pumpAndSettle();

      // Board is reset to 0 moves and original ball layout
      expect(find.text('Moves: 0'), findsOneWidget);
      final tube0 = tester.widget<TubeWidget>(find.byKey(const ValueKey('tube_0')));
      final tube2 = tester.widget<TubeWidget>(find.byKey(const ValueKey('tube_2')));
      expect(tube0.tube.balls.length, equals(4));
      expect(tube2.tube.balls.length, equals(0));
    });

    testWidgets('pause modal restart chamber also triggers confirmation dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      // Make a move: 0 -> 2
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pumpAndSettle();

      // Open pause modal
      await tester.tap(find.byKey(const Key('header_home_button')));
      await tester.pumpAndSettle();

      expect(find.text('MISSION PAUSED'), findsOneWidget);

      // Tap RESTART CHAMBER
      await tester.tap(find.byKey(const Key('pause_restart_button')));
      await tester.pumpAndSettle();

      // Confirmation dialog is shown
      expect(find.text('Restart this level?'), findsOneWidget);

      // Confirm
      await tester.tap(find.byKey(const Key('restart_confirm_button')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 0'), findsOneWidget);
    });

    testWidgets('restarting while hint is requested invalidates pending hints safely', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      // Request hint
      await tester.tap(find.byKey(const Key('hint_button')));
      await tester.pump();

      // Restart immediately with 0 moves
      await tester.tap(find.byKey(const Key('restart_button')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 0'), findsOneWidget);
      final tubes = tester.widgetList<TubeWidget>(find.byType(TubeWidget));
      expect(tubes.any((t) => t.isHinted), isFalse);
    });
  });
}
