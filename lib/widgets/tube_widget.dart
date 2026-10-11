import 'package:flutter/material.dart';

import '../game/tube.dart';
import '../theme/app_theme.dart';
import 'ball_widget.dart';

/// Translucent glass tube presentation widget styled after the Stitch design system.
///
/// Features:
/// - Open top with glowing frosted glass rim lip.
/// - Rounded base with glass specular highlights and inner reflections.
/// - Clear drop cue and target highlighting for empty/target vessels.
/// - Smooth pulse/glow effect when selected as active source.
class TubeWidget extends StatelessWidget {
  final Tube tube;
  final bool isSelected;
  final VoidCallback onTap;
  final double ballSize;
  final Set<int>? hiddenBallSlots;
  final int? hiddenBallSlot;
  final bool isDropTarget;

  const TubeWidget({
    super.key,
    required this.tube,
    required this.isSelected,
    required this.onTap,
    this.ballSize = 48.0,
    this.hiddenBallSlot,
    this.hiddenBallSlots,
    this.isDropTarget = false,
  });

  /// Whether slot [index] is currently hidden for animation.
  bool isSlotHidden(int index) {
    if (hiddenBallSlot == index) {
      return true;
    }
    if (hiddenBallSlots != null && hiddenBallSlots!.contains(index)) {
      return true;
    }
    return false;
  }

  /// Computes the vertical center position in local coordinates for a ball at [slotIndex].
  static double ballCenterY({
    required double tubeTop,
    required double tubeHeight,
    required double ballSize,
    required int slotIndex,
  }) {
    // 14.0 accommodates 10.0 bottom padding + 4.0 bottom clearance.
    return (tubeTop + tubeHeight) -
        14.0 -
        (slotIndex * (ballSize + 4.0)) -
        (ballSize / 2);
  }

  @override
  Widget build(BuildContext context) {
    final tubeWidth = ballSize + 16.0;
    final tubeHeight =
        (tube.capacity * ballSize) + ((tube.capacity + 1) * 6.0) + 16.0;

    final borderColor = isSelected
        ? AppTheme.secondary
        : (isDropTarget ? AppTheme.tertiary : Colors.white.withAlpha(45));

    final rimGlowColor = isSelected
        ? AppTheme.secondary.withAlpha(150)
        : (isDropTarget
              ? AppTheme.tertiary.withAlpha(160)
              : Colors.white.withAlpha(30));

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Tube with ${tube.balls.length} of ${tube.capacity} balls',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: tubeWidth,
          height: tubeHeight + 8.0, // extra height for open rim lip
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Glowing Rim Lip at the open top
              Positioned(
                top: 0,
                left: 1,
                right: 1,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(100),
                        rimGlowColor,
                        Colors.white.withAlpha(70),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: rimGlowColor,
                        blurRadius: isSelected || isDropTarget ? 12 : 4,
                        spreadRadius: isSelected ? 1 : 0,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Translucent Glass Cylinder Vessel
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryContainer.withAlpha(40)
                        : (isDropTarget
                              ? AppTheme.tertiary.withAlpha(20)
                              : Colors.white.withAlpha(14)),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0),
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                    border: Border(
                      left: BorderSide(
                        color: borderColor,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      right: BorderSide(
                        color: borderColor,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      bottom: BorderSide(
                        color: borderColor,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      top: BorderSide.none,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(130),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                      if (isSelected)
                        BoxShadow(
                          color: AppTheme.secondary.withAlpha(80),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      if (isDropTarget)
                        BoxShadow(
                          color: AppTheme.tertiary.withAlpha(90),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                    left: 4.0,
                    right: 4.0,
                    top: 6.0,
                  ),
                  child: Stack(
                    children: [
                      // Glass specular highlight streak (left edge)
                      Positioned(
                        left: 2,
                        top: 6,
                        bottom: 16,
                        width: 2.5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withAlpha(90),
                                Colors.white.withAlpha(20),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Empty tube drop cue indicator
                      if (tube.isEmpty)
                        Center(
                          child: Opacity(
                            opacity: isDropTarget ? 0.9 : 0.35,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  color: isDropTarget
                                      ? AppTheme.tertiary
                                      : AppTheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: isDropTarget
                                        ? AppTheme.tertiary
                                        : AppTheme.onSurfaceVariant,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Ball stack (index 0 at bottom)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          verticalDirection: VerticalDirection.up,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < tube.balls.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: isSlotHidden(i)
                                    ? SizedBox(
                                        width: ballSize,
                                        height: ballSize,
                                      )
                                    : BallWidget(
                                        type: tube.balls[i],
                                        size: ballSize,
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
