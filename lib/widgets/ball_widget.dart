import 'package:flutter/material.dart';

import '../game/ball_type.dart';

/// Skeuomorphic 3D spherical ball widget styled according to the Stitch design system.
///
/// Features:
/// - Radial gradient simulating spherical 3D surface shading.
/// - Specular highlight near top-left mimicking directional studio lighting.
/// - Inner rim soft ambient light reflection near bottom-right.
/// - Soft contact drop shadow underneath.
class BallWidget extends StatelessWidget {
  final BallType type;
  final double size;

  const BallWidget({super.key, required this.type, this.size = 48.0});

  /// Map BallType logical enum to the Stitch radial gradient color stops.
  static List<Color> gradientColorsForType(BallType type) {
    switch (type) {
      case BallType.red:
        // Ruby Red: highlight #ff9ebb, primary #f43f5e, dark #9f1239, core #4c0519
        return const [
          Color(0xFFFF9EBB),
          Color(0xFFF43F5E),
          Color(0xFF9F1239),
          Color(0xFF4C0519),
        ];
      case BallType.blue:
        // Neon Cyan / Sapphire Blue: highlight #acedff, primary #06b6d4, dark #0891b2, core #164e63
        return const [
          Color(0xFFACEDFF),
          Color(0xFF06B6D4),
          Color(0xFF0891B2),
          Color(0xFF164E63),
        ];
      case BallType.yellow:
        // Amber Gold: highlight #fde68a, primary #f59e0b, dark #b45309, core #78350f
        return const [
          Color(0xFFFDE68A),
          Color(0xFFF59E0B),
          Color(0xFFB45309),
          Color(0xFF78350F),
        ];
      case BallType.green:
        // Emerald Green: highlight #a7f3d0, primary #10b981, dark #047857, core #064e3b
        return const [
          Color(0xFFA7F3D0),
          Color(0xFF10B981),
          Color(0xFF047857),
          Color(0xFF064E3B),
        ];
      case BallType.purple:
        // Amethyst Purple: highlight #ede0ff, primary #d2bbff, dark #7c3aed, core #3f008e
        return const [
          Color(0xFFEDE0FF),
          Color(0xFFD2BBFF),
          Color(0xFF7C3AED),
          Color(0xFF3F008E),
        ];
    }
  }

  /// Backward-compatible primary color getter.
  static Color colorForBallType(BallType type) {
    return gradientColorsForType(type)[1];
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientColorsForType(type);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.85,
          colors: colors,
          stops: const [0.0, 0.35, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(110),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: colors[1].withAlpha(70),
            blurRadius: 10,
            spreadRadius: -1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gloss specular top-left highlight
          Positioned(
            top: size * 0.12,
            left: size * 0.18,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: size * 0.32,
                height: size * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size),
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ),
          ),
          // Subtle inner bottom rim bounce
          Positioned(
            bottom: size * 0.1,
            right: size * 0.2,
            child: Container(
              width: size * 0.25,
              height: size * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                color: Colors.white.withAlpha(45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
