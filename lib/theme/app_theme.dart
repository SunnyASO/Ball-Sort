import 'package:flutter/material.dart';

/// Cosmic theme tokens matching the Stitch design system.
class AppTheme {
  // Surface & Background Colors
  static const Color surface = Color(0xFF151024);
  static const Color surfaceDim = Color(0xFF151024);
  static const Color surfaceBright = Color(0xFF3B364B);
  static const Color surfaceContainerLowest = Color(0xFF0F0B1E);
  static const Color surfaceContainerLow = Color(0xFF1D192C);
  static const Color surfaceContainer = Color(0xFF211D31);
  static const Color surfaceContainerHigh = Color(0xFF2B273C);
  static const Color surfaceContainerHighest = Color(0xFF363247);

  // Content / Foreground Colors
  static const Color onSurface = Color(0xFFE7DEFA);
  static const Color onSurfaceVariant = Color(0xFFCCC3D8);
  static const Color outline = Color(0xFF958DA1);
  static const Color outlineVariant = Color(0xFF4A4455);

  // Primary (Electric Lavender / Violet)
  static const Color primary = Color(0xFFD2BBFF);
  static const Color onPrimary = Color(0xFF3F008E);
  static const Color primaryContainer = Color(0xFF7C3AED);
  static const Color onPrimaryContainer = Color(0xFFEDE0FF);

  // Secondary (Golden Amber)
  static const Color secondary = Color(0xFFFFB95F);
  static const Color onSecondary = Color(0xFF472A00);
  static const Color secondaryContainer = Color(0xFFEE9800);
  static const Color onSecondaryContainer = Color(0xFF5B3800);
  static const Color secondaryFixed = Color(0xFFFFDDB8);

  // Tertiary (Neon Cyan)
  static const Color tertiary = Color(0xFF4CD7F6);
  static const Color onTertiary = Color(0xFF003640);
  static const Color tertiaryContainer = Color(0xFF007184);
  static const Color tertiaryFixed = Color(0xFFACEDFF);
  static const Color tertiaryFixedDim = Color(0xFF4CD7F6);

  // Error (Coral Red)
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Glass tube gradients and styling
  static const Color glassRimBorder = Color(0x66FFFFFF);
  static const Color glassSurface = Color(0x0FFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        onSurface: onSurface,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
      ),
      fontFamily: 'Quicksand',
    );
  }
}
