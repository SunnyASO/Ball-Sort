import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/game_controller.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/levels/prototype_levels.dart';
import 'package:ball_sort/screens/game_screen.dart';
import 'package:ball_sort/widgets/ball_widget.dart';
import 'package:ball_sort/widgets/tube_widget.dart';

void main() {
  group('GameScreen Widget Tests', () {
    testWidgets(
      'initial rendering displays header, 4 tubes, 8 balls, and 0 moves',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: GameScreen()));

        // Verify Header
        expect(find.text('Ball Sort'), findsOneWidget);
        expect(find.text('Level 1'), findsOneWidget);
        expect(find.text('Moves: 0'), findsOneWidget);
        expect(find.byKey(const Key('restart_button')), findsOneWidget);

        // Verify 4 tubes rendered
        expect(find.byType(TubeWidget), findsNWidgets(4));
        expect(find.byKey(const ValueKey('tube_0')), findsOneWidget);
        expect(find.byKey(const ValueKey('tube_1')), findsOneWidget);
        expect(find.byKey(const ValueKey('tube_2')), findsOneWidget);
        expect(find.byKey(const ValueKey('tube_3')), findsOneWidget);

        // Verify exactly 8 balls rendered (4 red, 4 blue)
        expect(find.byType(BallWidget), findsNWidgets(8));

        // Victory banner must not be visible
        expect(find.byKey(const Key('victory_banner')), findsNothing);
      },
    );

    testWidgets('tube selection and deselection through taps', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      // Tap Tube 0 to select it
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();

      // Tube 0 should now be selected
      final tube0Finder = find.byKey(const ValueKey('tube_0'));
      final tube0Widget = tester.widget<TubeWidget>(tube0Finder);
      expect(tube0Widget.isSelected, isTrue);

      // Tap Tube 0 again to deselect
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();

      final tube0Deselected = tester.widget<TubeWidget>(tube0Finder);
      expect(tube0Deselected.isSelected, isFalse);
    });

    testWidgets(
      'valid transfer updates UI, ball positions, and increments move count',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: GameScreen()));

        // Tap Tube 0 (source), then Tube 2 (empty destination)
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_2')));
        await tester.pump();

        // Move count must increment to 1
        expect(find.text('Moves: 1'), findsOneWidget);

        // Selection must be cleared
        final tube0Widget = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_0')),
        );
        final tube2Widget = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_2')),
        );
        expect(tube0Widget.isSelected, isFalse);
        expect(tube2Widget.isSelected, isFalse);

        // Tube 0 should now have 3 balls, Tube 2 should have 1 ball
        expect(tube0Widget.tube.balls.length, equals(3));
        expect(tube2Widget.tube.balls.length, equals(1));
        expect(tube2Widget.tube.balls.first, equals(BallType.blue));

        // Total balls remains 8
        expect(find.byType(BallWidget), findsNWidgets(8));
      },
    );

    testWidgets(
      'invalid transfer leaves board and move count unchanged, switches selection if non-empty',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: GameScreen()));

        // Tube 0 top is blue, Tube 1 top is red
        // Tap Tube 0, then tap Tube 1 (invalid move)
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_1')));
        await tester.pump();

        // Move count remains 0
        expect(find.text('Moves: 0'), findsOneWidget);

        // Selection switched to Tube 1 because Tube 1 is non-empty
        final tube1Widget = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_1')),
        );
        expect(tube1Widget.isSelected, isTrue);

        final tube0Widget = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_0')),
        );
        expect(tube0Widget.isSelected, isFalse);

        // Balls unchanged
        expect(tube0Widget.tube.balls.length, equals(4));
        expect(tube1Widget.tube.balls.length, equals(4));
      },
    );

    testWidgets(
      'restart button restores initial board state and resets moves',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: GameScreen()));

        // Perform a move: 0 -> 2
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_2')));
        await tester.pumpAndSettle();

        expect(find.text('Moves: 1'), findsOneWidget);

        // Press restart and confirm in dialog
        await tester.tap(find.byKey(const Key('restart_button')));
        await tester.pumpAndSettle();
        expect(find.text('Restart this level?'), findsOneWidget);
        await tester.tap(find.byKey(const Key('restart_confirm_button')));
        await tester.pumpAndSettle();

        // Verify reset to 0 moves and initial ball distribution
        expect(find.text('Moves: 0'), findsOneWidget);

        final tube0 = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_0')),
        );
        final tube2 = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_2')),
        );
        expect(tube0.tube.balls.length, equals(4));
        expect(tube2.tube.balls.length, equals(0));
      },
    );

    testWidgets(
      'victory banner appears on win and Play Again restarts the game',
      (WidgetTester tester) async {
        // Setup a 1-move-to-win board
        final nearSolvedBoard = BallSortBoard([
          Tube(
            capacity: 4,
            balls: [BallType.red, BallType.red, BallType.red],
          ), // 0: needs 1 red
          Tube(capacity: 4, balls: [BallType.red]), // 1: top is red
          Tube(
            capacity: 4,
            balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
          ), // 2: complete
          Tube(capacity: 4), // 3: empty
        ]);

        final controller = GameController(initialBoard: nearSolvedBoard);

        await tester.pumpWidget(
          MaterialApp(home: GameScreen(controller: controller)),
        );

        expect(find.byKey(const Key('victory_banner')), findsNothing);

        // Move red from Tube 1 to Tube 0
        await tester.tap(find.byKey(const ValueKey('tube_1')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pumpAndSettle();

        // Victory banner must appear
        expect(find.byKey(const Key('victory_banner')), findsOneWidget);
        expect(find.text('Level Completed!'), findsOneWidget);
        expect(find.text('Solved in 1 moves'), findsOneWidget);

        // Click "Play Again" button on victory banner
        await tester.tap(find.byKey(const Key('play_again_button')));
        await tester.pump();

        // Victory banner should be gone, and moves reset to 0
        expect(find.byKey(const Key('victory_banner')), findsNothing);
        expect(find.text('Moves: 0'), findsOneWidget);
      },
    );

    testWidgets(
      'undo button is disabled at start and enabled after successful move, restoring visual state on tap',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: GameScreen()));

        final undoButtonFinder = find.byKey(const Key('undo_button'));
        expect(undoButtonFinder, findsOneWidget);

        // Initially moves: 0, undo is disabled (pressing it does nothing)
        await tester.tap(undoButtonFinder);
        await tester.pump();
        expect(find.text('Moves: 0'), findsOneWidget);

        // Make move 0 -> 2
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_2')));
        await tester.pumpAndSettle();

        expect(find.text('Moves: 1'), findsOneWidget);

        // Tap Undo button
        await tester.tap(undoButtonFinder);
        await tester.pump();

        // Moves should be 0 again
        expect(find.text('Moves: 0'), findsOneWidget);

        // Tube 0 should have 4 balls again, Tube 2 should be empty
        final tube0 = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_0')),
        );
        final tube2 = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_2')),
        );
        expect(tube0.tube.balls.length, equals(4));
        expect(tube2.tube.balls.length, equals(0));
      },
    );

    testWidgets(
      'next level button appears following victory and loads the next level board',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: GameScreen(initialLevelNumber: 1)),
        );

        // Fast solve Level 1:
        // T0 -> T2, T1 -> T3, T1 -> T2, T0 -> T3, T0 -> T2, T1 -> T3, T0 -> T3, T1 -> T2
        final moves = [
          (0, 2),
          (1, 3),
          (1, 2),
          (0, 3),
          (0, 2),
          (1, 3),
          (0, 3),
          (1, 2),
        ];

        for (final (from, to) in moves) {
          await tester.tap(find.byKey(ValueKey('tube_$from')));
          await tester.pump();
          await tester.tap(find.byKey(ValueKey('tube_$to')));
          await tester.pumpAndSettle();
        }

        expect(find.byKey(const Key('victory_banner')), findsOneWidget);
        expect(find.byKey(const Key('next_level_button')), findsOneWidget);

        // Tap Next Level
        await tester.tap(find.byKey(const Key('next_level_button')));
        await tester.pump();

        // Level 2 loaded!
        expect(find.text('Level 2'), findsOneWidget);
        expect(find.text('Moves: 0'), findsOneWidget);
        expect(find.byKey(const Key('victory_banner')), findsNothing);

        // Level 2 has 5 tubes
        expect(find.byType(TubeWidget), findsNWidgets(5));
      },
    );

    testWidgets(
      'completing Level 6 displays prototype completion message without Next Level button',
      (WidgetTester tester) async {
        final nearSolvedLevel6 = BallSortBoard([
          Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.red]),
          Tube(capacity: 4, balls: [BallType.red]),
          Tube(
            capacity: 4,
            balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.green,
              BallType.green,
              BallType.green,
              BallType.green,
            ],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.yellow,
              BallType.yellow,
              BallType.yellow,
              BallType.yellow,
            ],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.purple,
              BallType.purple,
              BallType.purple,
              BallType.purple,
            ],
          ),
          Tube(capacity: 4),
        ]);

        final controller = GameController(initialBoard: nearSolvedLevel6);

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(controller: controller, initialLevelNumber: 6),
          ),
        );

        // Move 1 -> 0 to solve Level 6
        await tester.tap(find.byKey(const ValueKey('tube_1')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('victory_banner')), findsOneWidget);
        expect(find.text('All Prototype Levels Complete!'), findsOneWidget);
        expect(find.byKey(const Key('next_level_button')), findsNothing);
        expect(find.byKey(const Key('play_again_button')), findsOneWidget);
      },
    );

    testWidgets(
      'all prototype levels (4, 5, 6, and 7 tubes) render without overflow on various phone sizes',
      (WidgetTester tester) async {
        final screenSizes = [
          const Size(320, 568), // Small phone (iPhone SE 1st gen size)
          const Size(360, 640), // Typical compact Android phone
          const Size(412, 915), // Pixel 6
        ];

        for (final size in screenSizes) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          for (int level = 1; level <= 6; level++) {
            await tester.pumpWidget(
              MaterialApp(
                home: GameScreen(
                  key: ValueKey('screen_level_$level'),
                  initialLevelNumber: level,
                ),
              ),
            );
            await tester.pumpAndSettle();

            final exception = tester.takeException();
            expect(
              exception,
              isNull,
              reason:
                  'Level $level should render without overflow at size $size',
            );

            // Correct tube count present
            final expectedTubes = PrototypeLevels.getLevel(level).tubeCount;
            expect(
              find.byType(TubeWidget),
              findsNWidgets(expectedTubes),
              reason: 'Level $level should display $expectedTubes tubes',
            );
          }
        }
      },
    );

    testWidgets(
      'completing Level 20 shows Next Level button and transitions to Level 21',
      (WidgetTester tester) async {
        final nearSolvedLevel20 = BallSortBoard([
          Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.red]),
          Tube(capacity: 4, balls: [BallType.red]),
          Tube(
            capacity: 4,
            balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.green,
              BallType.green,
              BallType.green,
              BallType.green,
            ],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.yellow,
              BallType.yellow,
              BallType.yellow,
              BallType.yellow,
            ],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.purple,
              BallType.purple,
              BallType.purple,
              BallType.purple,
            ],
          ),
          Tube(capacity: 4),
        ]);

        final controller = GameController(initialBoard: nearSolvedLevel20);

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              controller: controller,
              initialLevelNumber: 20,
              maxLevels: 50,
            ),
          ),
        );

        // Tap Tube 1 -> Tube 0 to complete Level 20
        await tester.tap(find.byKey(const ValueKey('tube_1')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('victory_banner')), findsOneWidget);
        expect(find.byKey(const Key('next_level_button')), findsOneWidget);

        // Tap Next Level button
        await tester.tap(find.byKey(const Key('next_level_button')));
        await tester.pumpAndSettle();

        // Level 21 loaded!
        expect(find.text('Level 21'), findsOneWidget);
        expect(find.text('Moves: 0'), findsOneWidget);
        expect(find.byKey(const Key('victory_banner')), findsNothing);

        // Level 21 has 6 tubes
        expect(find.byType(TubeWidget), findsNWidgets(6));
      },
    );

    testWidgets(
      'completing Level 50 shows campaign victory without Next Level button',
      (WidgetTester tester) async {
        final nearSolvedLevel50 = BallSortBoard([
          Tube(
            capacity: 4,
            balls: [BallType.purple, BallType.purple, BallType.purple],
          ),
          Tube(capacity: 4, balls: [BallType.purple]),
          Tube(
            capacity: 4,
            balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.green,
              BallType.green,
              BallType.green,
              BallType.green,
            ],
          ),
          Tube(
            capacity: 4,
            balls: [
              BallType.yellow,
              BallType.yellow,
              BallType.yellow,
              BallType.yellow,
            ],
          ),
          Tube(
            capacity: 4,
            balls: [BallType.red, BallType.red, BallType.red, BallType.red],
          ),
          Tube(capacity: 4),
        ]);

        final controller = GameController(initialBoard: nearSolvedLevel50);

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              controller: controller,
              initialLevelNumber: 50,
              maxLevels: 50,
            ),
          ),
        );

        // Tap Tube 1 -> Tube 0 to complete Level 50
        await tester.tap(find.byKey(const ValueKey('tube_1')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('victory_banner')), findsOneWidget);
        expect(find.byKey(const Key('next_level_button')), findsNothing);
        expect(find.byKey(const Key('play_again_button')), findsOneWidget);
      },
    );
  });
}
