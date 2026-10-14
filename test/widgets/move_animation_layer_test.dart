import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/widgets/ball_widget.dart';
import 'package:ball_sort/widgets/move_animation_layer.dart';
import 'package:ball_sort/widgets/tube_widget.dart';

void main() {
  group('MoveAnimationLayer Unit and Widget Tests', () {
    test('calculatePosition continuous parametric arc trajectory', () {
      const data = TransferAnimationData(
        ballType: BallType.red,
        sourceBallCenter: Offset(100, 300),
        destBallCenter: Offset(200, 300),
        clearanceY: 100,
        ballSize: 40,
      );

      final layer = MoveAnimationLayer(
        animation: const AlwaysStoppedAnimation(0.0),
        data: data,
      );

      // t = 0.0: starts at source ball center
      expect(layer.calculatePosition(0.0), equals(const Offset(100, 300)));

      // Early lift (t = 0.10): vertically exiting source tube mouth (x stays 100)
      final earlyLift = layer.calculatePosition(0.10);
      expect(earlyLift.dx, equals(100.0));
      expect(earlyLift.dy, inExclusiveRange(94.0, 300.0));

      // Mid-flight apex (t = 0.50): approximately at horizontal midpoint and cresting at arc apex
      final apex = layer.calculatePosition(0.50);
      expect(apex.dx, closeTo(150.0, 2.0));
      expect(apex.dy, equals(94.0)); // clearance 100 - arc crest 6.0

      // Descent into destination (t = 0.90): horizontally aligned with destination column
      final lateDescent = layer.calculatePosition(0.90);
      expect(lateDescent.dx, equals(200.0));
      expect(lateDescent.dy, inExclusiveRange(94.0, 300.0));

      // t = 1.0: settles precisely at destination ball center
      expect(layer.calculatePosition(1.0), equals(const Offset(200, 300)));
    });

    test('calculatePosition grouped move lead-follow micro-stagger', () {
      const data = TransferAnimationData(
        ballType: BallType.blue,
        sourceBallCenters: [Offset(100, 260), Offset(100, 300)],
        destBallCenters: [Offset(200, 260), Offset(200, 300)],
        clearanceY: 100,
        ballSize: 40,
      );

      final layer = MoveAnimationLayer(
        animation: const AlwaysStoppedAnimation(0.0),
        data: data,
      );

      expect(data.ballCount, equals(2));

      // At start (t = 0.0), both balls start at their respective source slots
      expect(layer.calculatePosition(0.0, 0), equals(const Offset(100, 260)));
      expect(layer.calculatePosition(0.0, 1), equals(const Offset(100, 300)));

      // Lead ball (index 0) initiates flight ahead of trailing ball (index 1)
      final leadMid = layer.calculatePosition(0.20, 0);
      final trailMid = layer.calculatePosition(0.20, 1);
      // Lead ball has progressed further along its trajectory (lower dy = higher in the air)
      expect(leadMid.dy, lessThan(trailMid.dy));

      // At completion (t = 1.0), both balls settle at their respective dest slots
      expect(layer.calculatePosition(1.0, 0), equals(const Offset(200, 260)));
      expect(layer.calculatePosition(1.0, 1), equals(const Offset(200, 300)));
    });

    testWidgets('renders flying ball at calculated position', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: const [
                _TestAnimationHost(
                  animationData: TransferAnimationData(
                    ballType: BallType.blue,
                    sourceBallCenter: Offset(50, 200),
                    destBallCenter: Offset(150, 200),
                    clearanceY: 50,
                    ballSize: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(MoveAnimationLayer), findsOneWidget);
      expect(find.byType(BallWidget), findsOneWidget);

      final ballWidget = tester.widget<BallWidget>(find.byType(BallWidget));
      expect(ballWidget.type, equals(BallType.blue));
      expect(ballWidget.size, equals(30));
    });

    testWidgets(
      'hiddenBallSlot in TubeWidget reserves exact space without BallWidget',
      (WidgetTester tester) async {
        final tube = Tube(capacity: 4, balls: [BallType.red, BallType.blue]);

        // Hidden slot 1 (the top ball, blue)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TubeWidget(
                  tube: tube,
                  isSelected: false,
                  onTap: () {},
                  hiddenBallSlot: 1,
                ),
              ),
            ),
          ),
        );

        // Only one BallWidget rendered (the red one at index 0)
        expect(find.byType(BallWidget), findsOneWidget);
        final renderedBall = tester.widget<BallWidget>(find.byType(BallWidget));
        expect(renderedBall.type, equals(BallType.red));

        // When hiddenBallSlot is null, both balls render
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TubeWidget(
                  tube: tube,
                  isSelected: false,
                  onTap: () {},
                  hiddenBallSlot: null,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(BallWidget), findsNWidgets(2));
      },
    );
  });
}

class _TestAnimationHost extends StatefulWidget {
  final TransferAnimationData animationData;

  const _TestAnimationHost({required this.animationData});

  @override
  State<_TestAnimationHost> createState() => _TestAnimationHostState();
}

class _TestAnimationHostState extends State<_TestAnimationHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MoveAnimationLayer(
      data: widget.animationData,
      animation: _controller,
    );
  }
}
