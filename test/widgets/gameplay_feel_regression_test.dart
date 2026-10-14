import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_sort_board.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/game_controller.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/screens/game_screen.dart';
import 'package:ball_sort/theme/game_theme.dart';
import 'package:ball_sort/widgets/move_animation_layer.dart';
import 'package:ball_sort/widgets/tube_widget.dart';

void main() {
  group('Gameplay Feel & Art Direction Regression Tests', () {
    testWidgets(
      'Unselected chambers maintain stable pristine glass brightness when another chamber is selected',
      (WidgetTester tester) async {
        final tube0 = Tube(balls: [BallType.red, BallType.blue]);
        final tube1 = Tube(balls: [BallType.red]);

        // When nothing is selected
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  TubeWidget(tube: tube0, isSelected: false, onTap: () {}),
                  TubeWidget(tube: tube1, isSelected: false, isDropTarget: false, onTap: () {}),
                ],
              ),
            ),
          ),
        );

        // Find the unselected chamber container
        final animatedContainersBefore = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decorationBefore = animatedContainersBefore.last.decoration as BoxDecoration;

        // Verify idle color is GameTheme.chamberGlass
        expect(decorationBefore.color, equals(GameTheme.chamberGlass));

        // When Tube 0 is selected and Tube 1 is a valid drop target
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  TubeWidget(tube: tube0, isSelected: true, onTap: () {}),
                  TubeWidget(tube: tube1, isSelected: false, isDropTarget: true, onTap: () {}),
                ],
              ),
            ),
          ),
        );

        final animatedContainersAfter = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decorationAfter = animatedContainersAfter.last.decoration as BoxDecoration;

        // Critical Regression Check: Unselected chamber MUST NOT darken or switch to dark blue!
        expect(
          decorationAfter.color,
          equals(GameTheme.chamberGlass),
          reason: 'Chamber background must remain stable GameTheme.chamberGlass without screen dimming',
        );

        // Border of unselected drop target must remain GameTheme.chamberBorder without harsh contrast jump
        final border = decorationAfter.border! as Border;
        expect(
          border.left.color,
          equals(GameTheme.chamberBorder),
          reason: 'Chamber border must remain clean GameTheme.chamberBorder without dark blue suppression',
        );
      },
    );

    testWidgets(
      'Selected chamber elevates top orb in anticipation pose and lifts vessel subtly',
      (WidgetTester tester) async {
        final tube = Tube(balls: [BallType.red, BallType.blue]);

        // Idle state: isSelected = false
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TubeWidget(tube: tube, isSelected: false, onTap: () {}),
              ),
            ),
          ),
        );

        // Find AnimatedSlides
        final slidesBefore = tester.widgetList<AnimatedSlide>(find.byType(AnimatedSlide));
        // All slides at Offset.zero
        for (final slide in slidesBefore) {
          expect(slide.offset, equals(Offset.zero));
        }

        // Active state: isSelected = true
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TubeWidget(tube: tube, isSelected: true, onTap: () {}),
              ),
            ),
          ),
        );

        final slidesAfter = tester.widgetList<AnimatedSlide>(find.byType(AnimatedSlide));
        // First slide is vessel lift
        final vesselSlide = slidesAfter.first;
        expect(vesselSlide.offset.dy, lessThan(0.0), reason: 'Vessel must lift subtly when selected');

        // Top ball slide (last slide) floats upward to open rim mouth
        final topBallSlide = slidesAfter.last;
        expect(topBallSlide.offset.dy, equals(-0.28), reason: 'Top ball must float upward by -0.28');
      },
    );

    test('Continuous parametric arc trajectory maintains velocity continuity', () {
      const data = TransferAnimationData(
        ballType: BallType.red,
        sourceBallCenter: Offset(80, 280),
        destBallCenter: Offset(240, 280),
        clearanceY: 80,
        ballSize: 44,
      );

      final layer = MoveAnimationLayer(
        animation: const AlwaysStoppedAnimation(0.0),
        data: data,
      );

      // Verify smooth monotonic horizontal advancement across mid flight
      double prevX = layer.calculatePosition(0.0).dx;
      for (double t = 0.05; t <= 1.0; t += 0.05) {
        final currentPos = layer.calculatePosition(t);
        expect(currentPos.dx, greaterThanOrEqualTo(prevX));
        prevX = currentPos.dx;
      }

      // Verify arc apex smoothly crests higher than clearanceY
      final apexPos = layer.calculatePosition(0.50);
      expect(apexPos.dy, lessThan(data.clearanceY), reason: 'Apex must crest gracefully above clearance plane');

      // Verify landing coordinates
      final endPos = layer.calculatePosition(1.0);
      expect(endPos, equals(const Offset(240, 280)));
    });

    testWidgets(
      'Full game flow executes smooth arc transfer and awards victory correctly',
      (WidgetTester tester) async {
        final nearSolvedBoard = BallSortBoard([
          Tube(capacity: 4, balls: [BallType.red, BallType.red, BallType.red]),
          Tube(capacity: 4, balls: [BallType.red]),
          Tube(capacity: 4, balls: [BallType.blue, BallType.blue, BallType.blue, BallType.blue]),
          Tube(capacity: 4),
        ]);

        final controller = GameController(initialBoard: nearSolvedBoard);

        await tester.pumpWidget(
          MaterialApp(home: GameScreen(controller: controller)),
        );

        // Tap tube 1 then tube 0
        await tester.tap(find.byKey(const ValueKey('tube_1')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('tube_0')));
        await tester.pump();

        // Transfer animation active
        expect(find.byType(MoveAnimationLayer), findsOneWidget);

        // Mid-flight pump
        await tester.pump(const Duration(milliseconds: 180));
        expect(find.byType(MoveAnimationLayer), findsOneWidget);

        // Settle animation
        await tester.pumpAndSettle();

        // Victory modal displayed
        expect(find.byKey(const Key('victory_banner')), findsOneWidget);
        expect(find.text('Level Completed!'), findsOneWidget);
      },
    );
  });
}
