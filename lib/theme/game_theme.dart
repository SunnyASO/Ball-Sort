import 'package:flutter/material.dart';

import '../game/ball_type.dart';

/// Centralized Orb Lab visual theme tokens, palette, and decoration helpers.
///
/// Aesthetic qualities:
/// - Futuristic clean energy laboratory
/// - Deep navy & midnight-blue containment environments
/// - Vibrant electric cyan, sapphire blue, neon violet & subtle magenta accents
/// - Glowing energy orbs with distinct chromatic cores
/// - Dark glass/metallic energy containment chambers with illuminated rim lines
class GameTheme {
  // Primary Orb Lab Palette
  static const Color background = Color(0xFF080F24);
  static const Color surface = Color(0xFF121D38);
  static const Color surfaceElevated = Color(0xFF1B2A4B);
  static const Color surfaceDim = Color(0xFF0A132C);
  static const Color surfaceHighlight = Color(0xFF24365D);

  // Energy Accents
  static const Color cyanAccent = Color(0xFF49DCEC);
  static const Color cyanGlow = Color(0xFF7AE7F5);
  static const Color blueAccent = Color(0xFF5A8DFF);
  static const Color violetAccent = Color(0xFFA178FF);
  static const Color magentaAccent = Color(0xFFFF5AA8);

  // Typography & Text
  static const Color textPrimary = Color(0xFFF2F7FF);
  static const Color textSecondary = Color(0xFF9DADCA);
  static const Color textTertiary = Color(0xFF65789B);
  static const Color textDisabled = Color(0xFF4A5873);

  // Chamber / Containment Vessel
  static const Color chamberGlass = Color(0x1F49DCEC);
  static const Color chamberBorder = Color(0x3849DCEC);
  static const Color chamberSelectedBorder = Color(0xFF49DCEC);
  static const Color chamberDropTargetBorder = Color(0xFF5A8DFF);
  static const Color chamberRimGlow = Color(0x6649DCEC);
  static const Color chamberBase = Color(0xFF1B2A4B);

  // Energy Orb Color Palettes (inner highlight, core glow, body, deep outer rim)
  static List<Color> orbColorsForType(BallType type) {
    switch (type) {
      case BallType.red:
        // Ruby Quantum Core
        return const [
          Color(0xFFFFB3C6), // internal specular highlight
          Color(0xFFFF3366), // primary energy core
          Color(0xFFC70039), // sphere mid-tone
          Color(0xFF4D0017), // deep rim shadow
        ];
      case BallType.blue:
        // Ion Sapphire / Electric Cyan
        return const [
          Color(0xFFB5F5FF), // internal specular highlight
          Color(0xFF00D2FF), // primary energy core
          Color(0xFF0072CE), // sphere mid-tone
          Color(0xFF00224D), // deep rim shadow
        ];
      case BallType.yellow:
        // Plasma Solar Amber
        return const [
          Color(0xFFFFF3B0), // internal specular highlight
          Color(0xFFFFB800), // primary energy core
          Color(0xFFD97706), // sphere mid-tone
          Color(0xFF5C2600), // deep rim shadow
        ];
      case BallType.green:
        // Tachyon Emerald
        return const [
          Color(0xFFC2FFD9), // internal specular highlight
          Color(0xFF00E676), // primary energy core
          Color(0xFF00964A), // sphere mid-tone
          Color(0xFF003816), // deep rim shadow
        ];
      case BallType.purple:
        // Dark Matter Amethyst / Hyper Violet
        return const [
          Color(0xFFEADBFF), // internal specular highlight
          Color(0xFFA855F7), // primary energy core
          Color(0xFF7E22CE), // sphere mid-tone
          Color(0xFF2E0854), // deep rim shadow
        ];
    }
  }

  /// Primary core color for a given BallType.
  static Color coreColorForType(BallType type) {
    return orbColorsForType(type)[1];
  }

  /// ThemeData configured for the Orb Lab environment.
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: cyanAccent,
        secondary: violetAccent,
        tertiary: blueAccent,
        onSurface: textPrimary,
        onPrimary: background,
        onSecondary: textPrimary,
      ),
      fontFamily: 'Quicksand',
    );
  }
}
