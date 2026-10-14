import 'package:flutter/material.dart';

import '../game/tube.dart';
import '../theme/game_theme.dart';
import 'ball_widget.dart';

/// Futuristic containment chamber widget styled after the Orb Lab aesthetic.
///
/// Features:
/// - Dark, translucent cyan-tinted energy cylinder vessel.
/// - Illuminated containment rim lip at the open top with energetic glow.
/// - Mechanical base socket support with futuristic bevelled feet.
/// - Vertical optical laser-guide markings and specular edge highlights.
/// - Active selection glow with energetic cyan outline.
/// - Drop target cue with sapphire blue guide beacon.
/// - Clear, high-contrast FREE chamber indicator for empty vessels.
/// - Preserves all existing testing keys, geometry contracts, and multi-ball destination slot hiding.
class TubeWidget extends StatelessWidget {
  final Tube tube;
  final bool isSelected;
  final VoidCallback onTap;
  final double ballSize;
  final Set<int>? hiddenBallSlots;
  final int? hiddenBallSlot;
  final bool isDropTarget;
  final bool isHinted;

  const TubeWidget({
    super.key,
    required this.tube,
    required this.isSelected,
    required this.onTap,
    this.ballSize = 48.0,
    this.hiddenBallSlot,
    this.hiddenBallSlots,
    this.isDropTarget = false,
    this.isHinted = false,
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
        ? GameTheme.chamberSelectedBorder
        : (isHinted
              ? const Color(0xFFFFD700)
              : GameTheme.chamberBorder);

    final rimGlowColor = isSelected
        ? GameTheme.cyanAccent
        : (isHinted
              ? const Color(0xFFFFD700)
              : (isDropTarget
                    ? GameTheme.cyanAccent.withAlpha(140)
                    : GameTheme.chamberRimGlow));

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          'Containment Chamber with ${tube.balls.length} of ${tube.capacity} energy orbs',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedSlide(
          offset: isSelected ? const Offset(0, -0.015) : Offset.zero,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: tubeWidth,
            height:
                tubeHeight +
                10.0, // extra height for open rim lip and mechanical base
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Energetic Rim Lip at the open top of the chamber
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
                          Colors.white.withAlpha(140),
                          rimGlowColor,
                          Colors.white.withAlpha(90),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: rimGlowColor.withAlpha(isSelected ? 220 : 100),
                          blurRadius: isSelected || isDropTarget ? 14 : 5,
                          spreadRadius: isSelected ? 1.5 : 0,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Translucent Energy Containment Cylinder Vessel
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  bottom: 4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GameTheme.cyanAccent.withAlpha(35)
                          : GameTheme.chamberGlass,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28.0),
                        bottomRight: Radius.circular(28.0),
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
                          color: Colors.black.withAlpha(160),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                        if (isSelected)
                          BoxShadow(
                            color: GameTheme.cyanAccent.withAlpha(110),
                            blurRadius: 18,
                            spreadRadius: 2,
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
                      // Technical Measurement / Laser Alignment Marks (Right inner edge)
                      Positioned(
                        right: 3,
                        top: 12,
                        bottom: 24,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            tube.capacity,
                            (index) => Container(
                              width: 3.5,
                              height: 1.5,
                              color: isSelected
                                  ? GameTheme.cyanAccent.withAlpha(150)
                                  : GameTheme.chamberBorder.withAlpha(120),
                            ),
                          ),
                        ),
                      ),

                      // Specular Glass Reflection Streak (Left inner edge)
                      Positioned(
                        left: 2,
                        top: 6,
                        bottom: 16,
                        width: 2.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withAlpha(100),
                                Colors.white.withAlpha(25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Empty Containment Vessel Drop Beacon Indicator
                      if (tube.isEmpty)
                        Center(
                          child: Opacity(
                            opacity: isDropTarget ? 0.95 : 0.40,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  color: isDropTarget
                                      ? GameTheme.cyanAccent
                                      : GameTheme.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: isDropTarget
                                        ? GameTheme.cyanAccent
                                        : GameTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Energy Orb Stack (index 0 at bottom)
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
                                    : AnimatedSlide(
                                        offset: (isSelected &&
                                                i == tube.balls.length - 1)
                                            ? const Offset(0, -0.28)
                                            : Offset.zero,
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        curve: Curves.easeOutBack,
                                        child: BallWidget(
                                          type: tube.balls[i],
                                          size: ballSize,
                                        ),
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Futuristic Mechanical Base Socket Platform
              Positioned(
                bottom: 0,
                left: 3,
                right: 3,
                height: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: GameTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isSelected
                          ? GameTheme.cyanAccent.withAlpha(180)
                          : GameTheme.surfaceHighlight,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(120),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
