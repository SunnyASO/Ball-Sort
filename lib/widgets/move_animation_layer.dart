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
/// Follows a 3-stage kinematic path for each ball:
/// 1. Lift (0.0 - 0.25, ~100ms): Ball lifts vertically from source slot to clearance height.
/// 2. Horizontal (0.25 - 0.70, ~180ms): Ball travels smoothly above tubes to destination column.
/// 3. Drop (0.70 - 1.00, ~120ms): Ball drops vertically into the destination slot.
class MoveAnimationLayer extends StatelessWidget {
  final Animation<double> animation;
  final TransferAnimationData data;

  const MoveAnimationLayer({
    super.key,
    required this.animation,
    required this.data,
  });

  /// Computes the exact center (x, y) coordinates of the moving ball at index [ballIndex]
  /// at progress [t] in [0, 1].
  ///
  /// For grouped moves, ball [i] uses [clearanceY - (i * (ballSize + 4.0))] during flight
  /// to maintain clean vertical stacking without overlapping.
  Offset calculatePosition(double t, [int ballIndex = 0]) {
    final start = data.effectiveSourceCenters[ballIndex];
    final end = data.effectiveDestCenters[ballIndex];
    final spacing = data.ballSize + 4.0;
    final ballClearance = data.clearanceY - (ballIndex * spacing);

    if (t <= 0.25) {
      // Stage 1: Lift (0% to 25%)
      final p = (t / 0.25).clamp(0.0, 1.0);
      final curved = Curves.easeOutQuad.transform(p);
      final y = lerpDouble(start.dy, ballClearance, curved)!;
      return Offset(start.dx, y);
    } else if (t <= 0.70) {
      // Stage 2: Horizontal transfer (25% to 70%)
      final double curved;
      if (t >= 0.70) {
        curved = 1.0;
      } else {
        final p = ((t - 0.25) / 0.45).clamp(0.0, 1.0);
        curved = Curves.easeInOutCubic.transform(p);
      }
      final x = lerpDouble(start.dx, end.dx, curved)!;
      return Offset(x, ballClearance);
    } else {
      // Stage 3: Drop (70% to 100%)
      final double curved;
      if (t >= 1.0) {
        curved = 1.0;
      } else {
        final p = ((t - 0.70) / 0.30).clamp(0.0, 1.0);
        curved = Curves.easeInQuad.transform(p);
      }
      final y = lerpDouble(ballClearance, end.dy, curved)!;
      return Offset(end.dx, y);
    }
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
                  return Positioned(
                    left: pos.dx - (size / 2),
                    top: pos.dy - (size / 2),
                    child: IgnorePointer(
                      child: BallWidget(
                        key: ValueKey('moving_ball_$i'),
                        type: data.getBallType(i),
                        size: size,
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
