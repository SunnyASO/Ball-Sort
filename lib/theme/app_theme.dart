import 'package:flutter/material.dart';

import 'game_theme.dart';

/// Legacy alias connecting Stitch tokens to the centralized GameTheme Orb Lab palette.
/// Preserved to prevent breaking references across existing screens and widgets.
class AppTheme {
  // Surface & Background Colors
  static const Color surface = GameTheme.background;
  static const Color surfaceDim = GameTheme.surfaceDim;
  static const Color surfaceBright = GameTheme.surfaceElevated;
  static const Color surfaceContainerLowest = GameTheme.background;
  static const Color surfaceContainerLow = GameTheme.surfaceDim;
  static const Color surfaceContainer = GameTheme.surface;
  static const Color surfaceContainerHigh = GameTheme.surfaceElevated;
  static const Color surfaceContainerHighest = GameTheme.surfaceHighlight;

  // Content / Foreground Colors
  static const Color onSurface = GameTheme.textPrimary;
  static const Color onSurfaceVariant = GameTheme.textSecondary;
  static const Color outline = GameTheme.textTertiary;
  static const Color outlineVariant = GameTheme.textDisabled;

  // Primary (Electric Cyan in Orb Lab)
  static const Color primary = GameTheme.cyanAccent;
  static const Color onPrimary = GameTheme.background;
  static const Color primaryContainer = GameTheme.surfaceElevated;
  static const Color onPrimaryContainer = GameTheme.cyanGlow;

  // Secondary (Hyper Violet in Orb Lab)
  static const Color secondary = GameTheme.violetAccent;
  static const Color onSecondary = GameTheme.textPrimary;
  static const Color secondaryContainer = Color(0xFF6B3BC7);
  static const Color onSecondaryContainer = GameTheme.textPrimary;
  static const Color secondaryFixed = GameTheme.violetAccent;

  // Tertiary (Electric Sapphire Blue in Orb Lab)
  static const Color tertiary = GameTheme.blueAccent;
  static const Color onTertiary = GameTheme.textPrimary;
  static const Color tertiaryContainer = Color(0xFF1E3A8A);
  static const Color tertiaryFixed = GameTheme.cyanAccent;
  static const Color tertiaryFixedDim = GameTheme.blueAccent;

  // Error (Laser Red)
  static const Color error = Color(0xFFFF5252);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color onErrorContainer = Color(0xFFFFCDD2);

  // Glass chamber gradients and styling
  static const Color glassRimBorder = GameTheme.chamberRimGlow;
  static const Color glassSurface = GameTheme.chamberGlass;

  static ThemeData get darkTheme => GameTheme.themeData;
}
