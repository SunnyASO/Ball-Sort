import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/game_controller.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/screens/game_screen.dart';
import 'package:ball_sort/widgets/ball_widget.dart';
import 'package:ball_sort/widgets/move_animation_layer.dart';
import 'package:ball_sort/widgets/tube_widget.dart';

void main() {
  group('Milestone 0D Animation Integration Tests', () {
    testWidgets(
      'Total visible balls invariant holds during transfer animation',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: GameScreen()));

        // Initial ball count: 8 balls across tubes, 0 in animation layer
        expect(find.byType(BallWidget), findsNWidgets(8));

        // Tap Tube 0 (source)
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();

        // Tap Tube 2 (destination - empty)
        await tester.tap(find.byKey(const ValueKey('tube_2')));
        // Advance by 1 frame: animation starts
        await tester.pump();

        // Animation layer should be active with 1 flying ball
        expect(find.byType(MoveAnimationLayer), findsOneWidget);

        // Total rendered BallWidget must be exactly 8:
        // Tube 0 has 3, Tube 1 has 4, Tube 2 has 1 hidden, MoveAnimationLayer has 1
        // Total = 3 + 4 + 0 + 1 = 8. (NO DUPLICATE BALLS!)
        expect(find.byType(BallWidget), findsNWidgets(8));

        // Advance halfway through animation (200ms)
        await tester.pump(const Duration(milliseconds: 200));

        // Invariant still holds: exactly 8 balls visible
        expect(find.byType(BallWidget), findsNWidgets(8));
        expect(find.byType(MoveAnimationLayer), findsOneWidget);

        // Finish animation
        await tester.pumpAndSettle();

        // Animation layer gone, destination slot revealed: exactly 8 balls
        expect(find.byType(MoveAnimationLayer), findsNothing);
        expect(find.byType(BallWidget), findsNWidgets(8));
      },
    );

    testWidgets('Rapid taps and input are locked during transfer animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      // Move 0 -> 2
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_2')));
      await tester.pump(); // animation begins

      expect(find.byType(MoveAnimationLayer), findsOneWidget);

      // Rapidly tap other tubes during animation
      await tester.tap(find.byKey(const ValueKey('tube_1')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const ValueKey('tube_3')));
      await tester.pump(const Duration(milliseconds: 50));

      // Rapidly tap Undo and Restart during animation
      await tester.tap(find.byKey(const Key('undo_button')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const Key('restart_button')));
      await tester.pump(const Duration(milliseconds: 50));

      // Finish animation
      await tester.pumpAndSettle();

      // Move count must be 1 (taps during animation had no effect)
      expect(find.text('Moves: 1'), findsOneWidget);

      final tube1 = tester.widget<TubeWidget>(
        find.byKey(const ValueKey('tube_1')),
      );
      final tube3 = tester.widget<TubeWidget>(
        find.byKey(const ValueKey('tube_3')),
      );
      // Tube 1 is still untouched with 4 balls, Tube 3 is empty
      expect(tube1.tube.balls.length, equals(4));
      expect(tube3.tube.balls.length, equals(0));
    });

    testWidgets('Victory banner is deferred until transfer animation settles', (
      WidgetTester tester,
    ) async {
      // 1-move-to-win configuration
      final nearSolvedBoard = BallSortBoard([
        Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.red]),
        Tube(capacity: 4, balls: [BallType.red]),
        Tube(
          capacity: 4,
          balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue],
        ),
        Tube(capacity: 4),
      ]);

      final controller = GameController(initialBoard: nearSolvedBoard);

      await tester.pumpWidget(
        MaterialApp(home: GameScreen(controller: controller)),
      );

      // Perform winning move: 1 -> 0
      await tester.tap(find.byKey(const ValueKey('tube_1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tube_0')));
      await tester.pump(); // frame 1 of transfer

      // Transfer animation is running
      expect(find.byType(MoveAnimationLayer), findsOneWidget);

      // Authoritative state is already solved, but banner MUST NOT appear while animating
      expect(find.byKey(const Key('victory_banner')), findsNothing);

      // Advance partially (200ms)
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('victory_banner')), findsNothing);

      // Finish animation
      await tester.pumpAndSettle();

      // Now victory banner is displayed
      expect(find.byKey(const Key('victory_banner')), findsOneWidget);
      expect(find.text('Level Completed!'), findsOneWidget);
    });

    testWidgets(
      'Disposal during animation causes no unhandled exceptions or crashes',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: GameScreen()));

        // Start a transfer move: 0 -> 2
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_2')));
        await tester.pump(); // animating

        expect(find.byType(MoveAnimationLayer), findsOneWidget);

        // Replace screen immediately mid-flight
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: Text('Replaced'))),
        );

        // Settle any remaining timers/frames
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Replaced'), findsOneWidget);
      },
    );

    testWidgets(
      'Transfer animation functions correctly when tubes are horizontally scrolled',
      (WidgetTester tester) async {
        // Set phone size where 7 tubes overflow horizontally
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: GameScreen(initialLevelNumber: 6)),
        );
        await tester.pumpAndSettle();

        // Level 6 has 7 tubes (5 filled with 4 balls each = 20 balls total, 2 empty)
        expect(find.byType(BallWidget), findsNWidgets(20));

        // Scroll to the right so tube 6 is clearly visible
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(-200, 0),
        );
        await tester.pumpAndSettle();

        // Tap Tube 4 (source) then Tube 6 (destination empty tube)
        await tester.tap(find.byKey(const ValueKey('tube_4')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_6')));
        await tester.pump(); // Start transfer animation

        // Animation layer is active
        expect(find.byType(MoveAnimationLayer), findsOneWidget);
        // Total visible balls invariant holds (still exactly 20 balls)
        expect(find.byType(BallWidget), findsNWidgets(20));

        // Settle animation
        await tester.pumpAndSettle();

        expect(find.byType(MoveAnimationLayer), findsNothing);
        expect(find.byType(BallWidget), findsNWidgets(20));
        expect(find.text('Moves: 1'), findsOneWidget);

        // Verify tube 6 now has 1 ball
        final tube6 = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_6')),
        );
        expect(tube6.tube.balls.length, equals(1));
      },
    );

    testWidgets(
      'Grouped ball transfer animation preserves invariant and hides all destination slots',
      (WidgetTester tester) async {
        // Tube 0: [Red, Blue, Blue, Blue] (3 top blue balls)
        // Tube 1: Empty (capacity 4)
        final board = BallSortBoard([
          Tube(
            balls: [BallType.red, BallType.blue, BallType.blue, BallType.blue],
          ),
          Tube(),
        ]);

        final controller = GameController(initialBoard: board);

        await tester.pumpWidget(
          MaterialApp(home: GameScreen(controller: controller)),
        );

        // Initially: 4 balls in Tube 0, 0 in Tube 1 = 4 balls total
        expect(find.byType(BallWidget), findsNWidgets(4));

        // Tap Tube 0 then Tube 1
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_1')));
        await tester.pump(); // Start transfer animation

        // Animation layer is active with 3 moving balls
        expect(find.byType(MoveAnimationLayer), findsOneWidget);
        final layer = tester.widget<MoveAnimationLayer>(
          find.byType(MoveAnimationLayer),
        );
        expect(layer.data.ballCount, equals(3));

        // Invariant: Exactly 4 total BallWidgets rendered:
        // Tube 0: 1 red ball
        // Tube 1: 3 balls logically pushed, but all 3 are hidden in destination tube
        // MoveAnimationLayer: 3 flying blue balls
        // Total = 1 + 0 + 3 = 4.
        expect(find.byType(BallWidget), findsNWidgets(4));

        // Check key widgets: moving_ball_0, moving_ball_1, moving_ball_2
        expect(find.byKey(const ValueKey('moving_ball_0')), findsOneWidget);
        expect(find.byKey(const ValueKey('moving_ball_1')), findsOneWidget);
        expect(find.byKey(const ValueKey('moving_ball_2')), findsOneWidget);

        // Advance mid-flight (200ms)
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(BallWidget), findsNWidgets(4));

        // Complete animation
        await tester.pumpAndSettle();

        // Animation layer is dismissed
        expect(find.byType(MoveAnimationLayer), findsNothing);
        // Destination slots now revealed: 1 red in tube 0 + 3 blue in tube 1 = 4 balls total
        expect(find.byType(BallWidget), findsNWidgets(4));

        // Move count is 1
        expect(find.text('Moves: 1'), findsOneWidget);

        // Test undo of grouped transfer
        await tester.tap(find.byKey(const Key('undo_button')));
        await tester.pumpAndSettle();

        expect(find.text('Moves: 0'), findsOneWidget);
        final tube0 = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_0')),
        );
        final tube1 = tester.widget<TubeWidget>(
          find.byKey(const ValueKey('tube_1')),
        );
        expect(tube0.tube.balls.length, equals(4));
        expect(tube1.tube.isEmpty, isTrue);
      },
    );
  });
}
