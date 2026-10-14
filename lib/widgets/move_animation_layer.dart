import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../game/ball_type.dart';
import 'ball_widget.dart';

/// Presentation metadata defining a ball or grouped-ball transfer animation.
class TransferAnimationData {
  final List<Offset> sourceBallCenters;
  final List<Offset> destBallCenters;
  final double clearanceY;
  final BallType ballType;
  final List<BallType> ballTypes;
  final double ballSize;
  final Duration totalDuration;
  final Offset? _singleSourceBallCenter;
  final Offset? _singleDestBallCenter;

  const TransferAnimationData({
    Offset? sourceBallCenter,
    Offset? destBallCenter,
    List<Offset>? sourceBallCenters,
    List<Offset>? destBallCenters,
    required this.clearanceY,
    this.ballType = BallType.red,
    List<BallType>? ballTypes,
    required this.ballSize,
    this.totalDuration = const Duration(milliseconds: 400),
  }) : _singleSourceBallCenter = sourceBallCenter,
       _singleDestBallCenter = destBallCenter,
       sourceBallCenters = sourceBallCenters ?? const [],
       destBallCenters = destBallCenters ?? const [],
       ballTypes = ballTypes ?? const [];

  /// Returns effective source ball centers (supporting both single and grouped setups).
  List<Offset> get effectiveSourceCenters => sourceBallCenters.isNotEmpty
      ? sourceBallCenters
      : (_singleSourceBallCenter != null
            ? [_singleSourceBallCenter]
            : const []);

  /// Returns effective dest ball centers (supporting both single and grouped setups).
  List<Offset> get effectiveDestCenters => destBallCenters.isNotEmpty
      ? destBallCenters
      : (_singleDestBallCenter != null ? [_singleDestBallCenter] : const []);

  /// Convenience getter for single-ball backwards compatibility.
  Offset get sourceBallCenter =>
      _singleSourceBallCenter ??
      (sourceBallCenters.isNotEmpty ? sourceBallCenters.first : Offset.zero);

  Offset get destBallCenter => _singleDestDestCenter;

  Offset get _singleDestDestCenter =>
      _singleDestBallCenter ??
      (destBallCenters.isNotEmpty ? destBallCenters.first : Offset.zero);

  /// Count of balls being transferred in this animation group.
  int get ballCount => sourceBallCenters.isNotEmpty
      ? sourceBallCenters.length
      : (_singleSourceBallCenter != null ? 1 : 0);

  /// Gets the BallType for ball at index [index].
  BallType getBallType(int index) {
    if (index < ballTypes.length) return ballTypes[index];
    return ballType;
  }
}

/// Centralized presentation layer rendering the temporary moving balls during transfer.
///
/// Features a continuous parametric arc trajectory:
/// - Smooth vertical emergence from source chamber
/// - Seamless parabolic curve cresting gracefully over intervening chambers
/// - Continuous tangent velocities (no robotic 90-degree corners or midpoint stops)
/// - Fluid grouped train dynamics with lead-follow micro-stagger
/// - Controlled arrival deceleration with subtle landing micro-cushion
class MoveAnimationLayer extends StatelessWidget {
  final Animation<double> animation;
  final TransferAnimationData data;

  const MoveAnimationLayer({
    super.key,
    required this.animation,
    required this.data,
  });

  /// Computes local progress $\tau \in [0, 1]$ for ball at [ballIndex]
  /// applying lead-follow micro-staggering for grouped moves.
  double localProgress(double t, int ballIndex) {
    final count = data.ballCount;
    if (count <= 1) return t.clamp(0.0, 1.0);

    const double staggerStep = 0.04;
    final totalSpan = 1.0 - (staggerStep * (count - 1));
    final ballStart = staggerStep * ballIndex;
    return ((t - ballStart) / totalSpan).clamp(0.0, 1.0);
  }

  /// Computes the exact center (x, y) coordinates of the moving ball at index [ballIndex]
  /// at global progress [t] in [0, 1] using a continuous parametric arc.
  Offset calculatePosition(double t, [int ballIndex = 0]) {
    final tau = localProgress(t, ballIndex);
    final start = data.effectiveSourceCenters[ballIndex];
    final end = data.effectiveDestCenters[ballIndex];
    final spacing = data.ballSize + 4.0;
    final ballClearance = data.clearanceY - (ballIndex * spacing);

    // Dynamic arc crest height scaled subtly with horizontal distance
    final double dxAbs = (end.dx - start.dx).abs();
    final double arcCrest = (dxAbs < 1.0) ? 0.0 : math.min(14.0, dxAbs * 0.06);
    final double apexY = ballClearance - arcCrest;

    // Continuous Horizontal Trajectory X(tau)
    final double px;
    if (tau <= 0.18) {
      px = 0.0;
    } else if (tau >= 0.82) {
      px = 1.0;
    } else {
      final s = (tau - 0.18) / 0.64;
      px = Curves.easeInOutCubic.transform(s);
    }
    final x = lerpDouble(start.dx, end.dx, px)!;

    // Continuous Vertical Trajectory Y(tau) with smooth apex tangent
    final double y;
    if (tau <= 0.50) {
      final s = (tau / 0.50).clamp(0.0, 1.0);
      final curved = Curves.easeOutQuad.transform(s);
      y = lerpDouble(start.dy, apexY, curved)!;
    } else {
      final s = ((tau - 0.50) / 0.50).clamp(0.0, 1.0);
      final curved = Curves.easeInOutQuad.transform(s);
      y = lerpDouble(apexY, end.dy, curved)!;
    }

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final size = data.ballSize;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < data.ballCount; i++) ...[
              Builder(
                builder: (context) {
                  final pos = calculatePosition(t, i);
                  final tau = localProgress(t, i);

                  // Subtle landing micro-cushion upon touching down
                  double squash = 0.0;
                  if (tau >= 0.88) {
                    final p = (tau - 0.88) / 0.12;
                    squash = math.sin(p * math.pi) * 0.06;
                  }

                  return Positioned(
                    left: pos.dx - (size / 2),
                    top: pos.dy - (size / 2),
                    child: IgnorePointer(
                      child: Transform.scale(
                        scaleX: 1.0 + squash,
                        scaleY: 1.0 - squash,
                        child: BallWidget(
                          key: ValueKey('moving_ball_$i'),
                          type: data.getBallType(i),
                          size: size,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
