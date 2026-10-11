import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ball_sort/game/ball_type.dart';
import 'package:ball_sort/game/tube.dart';
import 'package:ball_sort/widgets/ball_widget.dart';
import 'package:ball_sort/widgets/move_animation_layer.dart';
import 'package:ball_sort/widgets/tube_widget.dart';

void main() {
  group('MoveAnimationLayer Unit and Widget Tests', () {
    test('calculatePosition 3-stage kinematic path', () {
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

      // t = 0.25 (end of lift): at lift clearance height
      expect(layer.calculatePosition(0.25), equals(const Offset(100, 100)));

      // t in (0.0, 0.25): purely vertical motion (x stays 100)
      final midLift = layer.calculatePosition(0.125);
      expect(midLift.dx, equals(100.0));
      expect(midLift.dy, inExclusiveRange(100.0, 300.0));

      // t = 0.70 (end of horizontal travel): at dest column at clearance height
      expect(layer.calculatePosition(0.70), equals(const Offset(200, 100)));

      // t in (0.25, 0.70): purely horizontal motion (y stays 100)
      final midTravel = layer.calculatePosition(0.475);
      expect(midTravel.dx, inExclusiveRange(100.0, 200.0));
      expect(midTravel.dy, equals(100.0));

      // t in (0.70, 1.0): purely vertical drop (x stays 200)
      final midDrop = layer.calculatePosition(0.85);
      expect(midDrop.dx, equals(200.0));
      expect(midDrop.dy, inExclusiveRange(100.0, 300.0));

      // t = 1.0: drops to destination ball center
      expect(layer.calculatePosition(1.0), equals(const Offset(200, 300)));
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
