import 'package:ball_sort/screens/game_screen.dart';
import 'package:ball_sort/widgets/tube_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Async Hint & UI Responsiveness Regression Tests', () {
    testWidgets('hint button highlights optimal source and destination tubes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      final hintButton = find.byKey(const Key('hint_button'));
      expect(hintButton, findsOneWidget);

      await tester.tap(hintButton);
      await tester.pumpAndSettle();

      // Check that at least one tube is highlighted with hint
      final tubes = tester.widgetList<TubeWidget>(find.byType(TubeWidget));
      final hasHint = tubes.any((t) => t.isHinted);
      expect(hasHint, isTrue);
    });

    testWidgets('multiple rapid hint taps do not trigger duplicate requests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 14)),
      );
      await tester.pumpAndSettle();

      final hintButton = find.byKey(const Key('hint_button'));

      // Rapidly tap hint 3 times
      await tester.tap(hintButton);
      await tester.pump();
      await tester.tap(hintButton, warnIfMissed: false);
      await tester.pump();
      await tester.tap(hintButton, warnIfMissed: false);

      // Pump until computation finishes
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });

    testWidgets('making a move while hint is pending invalidates stale hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      // Request hint
      await tester.tap(find.byKey(const Key('hint_button')));
      await tester.pump(); // Start hint calculation

      // Immediately perform a manual move: Tube 0 -> Tube 2
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 1'), findsOneWidget);

      // Ensure no stale hint remains active
      final tubes = tester.widgetList<TubeWidget>(find.byType(TubeWidget));
      final hasHint = tubes.any((t) => t.isHinted);
      expect(hasHint, isFalse);
    });

    testWidgets('tapping undo while hint is pending invalidates hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      // Make a move first
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pumpAndSettle();
      expect(find.text('Moves: 1'), findsOneWidget);

      // Request hint
      await tester.tap(find.byKey(const Key('hint_button')));
      await tester.pump();

      // Immediately tap Undo
      await tester.tap(find.byKey(const Key('undo_button')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 0'), findsOneWidget);

      final tubes = tester.widgetList<TubeWidget>(find.byType(TubeWidget));
      final hasHint = tubes.any((t) => t.isHinted);
      expect(hasHint, isFalse);
    });

    testWidgets('tapping restart while hint is pending invalidates hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
      );
      await tester.pumpAndSettle();

      // Request hint
      await tester.tap(find.byKey(const Key('hint_button')));
      await tester.pump();

      // Immediately tap Restart
      await tester.tap(find.byKey(const Key('restart_button')));
      await tester.pumpAndSettle();

      expect(find.text('Moves: 0'), findsOneWidget);

      final tubes = tester.widgetList<TubeWidget>(find.byType(TubeWidget));
      final hasHint = tubes.any((t) => t.isHinted);
      expect(hasHint, isFalse);
    });

    testWidgets('switching to Levels tab while hint is pending does not crash', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 14)),
      );
      await tester.pumpAndSettle();

      // Request hint
      await tester.tap(find.byKey(const Key('hint_button')));
      await tester.pump();

      // Switch to Levels tab
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();

      expect(find.text('ORB LAB'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposing GameScreen while hint is calculating is safe', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(initialLevelNumber: 14)),
      );
      await tester.pumpAndSettle();

      // Request hint on large level
      await tester.tap(find.byKey(const Key('hint_button')));
      await tester.pump();

      // Immediately dispose GameScreen by replacing home with an empty container
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
