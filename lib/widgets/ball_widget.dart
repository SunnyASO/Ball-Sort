import 'package:flutter/material.dart';

import '../game/ball_type.dart';
import '../theme/game_theme.dart';

/// Energy Orb Presentation Widget styled after the Orb Lab futuristic aesthetic.
///
/// Features:
/// - Smooth spherical 3D volumetric gradient with an illuminated plasma core.
/// - Concentric inner energy corona highlight with chromatic specular glow.
/// - Crisp, directional primary specular lens gleam (top-left).
/// - Translucent secondary rim bounce illumination (bottom-right).
/// - Restrained outer chromatic energy aura shadow.
/// - Lightweight, pure Flutter code rendering (no heavy run-time shaders or third-party engines).
class BallWidget extends StatelessWidget {
  final BallType type;
  final double size;

  const BallWidget({super.key, required this.type, this.size = 48.0});

  /// Map BallType logical enum to the 4-stop Orb Lab radial gradient colors.
  static List<Color> gradientColorsForType(BallType type) {
    return GameTheme.orbColorsForType(type);
  }

  /// Backward-compatible primary color getter.
  static Color colorForBallType(BallType type) {
    return GameTheme.coreColorForType(type);
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientColorsForType(type);
    final coreColor = colors[1];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Outer Chromatic Energy Glow / Aura
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: coreColor.withAlpha(85),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // 2. Volumetric Spherical Energy Body
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.30, -0.35),
                radius: 0.90,
                colors: colors,
                stops: const [0.0, 0.32, 0.72, 1.0],
              ),
              border: Border.all(color: colors[0].withAlpha(60), width: 0.75),
            ),
          ),

          // 3. Inner Plasma Corona (faint concentric energy ring)
          Positioned(
            top: size * 0.16,
            left: size * 0.16,
            child: Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.2),
                  radius: 0.8,
                  colors: [
                    Colors.white.withAlpha(110),
                    coreColor.withAlpha(40),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 4. Primary Specular Highlight (Micro Lens Reflection top-left)
          Positioned(
            top: size * 0.14,
            left: size * 0.20,
            child: Transform.rotate(
              angle: -0.25,
              child: Container(
                width: size * 0.34,
                height: size * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withAlpha(220),
                      Colors.white.withAlpha(70),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. Secondary Rim Bounce Light (Bottom-Right)
          Positioned(
            bottom: size * 0.10,
            right: size * 0.18,
            child: Container(
              width: size * 0.26,
              height: size * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                color: colors[0].withAlpha(60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
