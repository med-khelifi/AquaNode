import 'package:flutter/material.dart';

/// Centralized color palette and semantic colors for Aqua Node.
abstract final class AppColors {
  // Brand & Accent Colors
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color primaryDark = Color(0xFF7DB0FF);  // Soft Periwinkle Blue

  // Background & Surface Colors (Light)
  static const Color backgroundLight = Color(0xFFF5F7FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Background & Surface Colors (Dark)
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF111C2E);

  // Typography & Content Colors (Light)
  static const Color textLight = Color(0xFF172033);
  static const Color mutedLight = Color(0xFF647089);

  // Typography & Content Colors (Dark)
  static const Color textDark = Color(0xFFE8EEF8);
  static const Color mutedDark = Color(0xFFA5B3C9);

  // Semantic Status Colors (Light)
  static const Color successLight = Color(0xFF15803D);
  static const Color warningLight = Color(0xFFB45309);
  static const Color errorLight = Color(0xFFB91C1C);
  static const Color neutralLight = Color(0xFF647089);

  // Semantic Status Colors (Dark)
  static const Color successDark = Color(0xFF69D391);
  static const Color warningDark = Color(0xFFF4BD62);
  static const Color errorDark = Color(0xFFFF8585);
  static const Color neutralDark = Color(0xFFA5B3C9);

  // Material 3 ColorScheme - Light
  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryLight,
        onPrimary: Colors.white,
        surface: surfaceLight,
        onSurface: textLight,
        error: errorLight,
        outlineVariant: mutedLight.withValues(alpha: 0.3),
      );

  // Material 3 ColorScheme - Dark
  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryDark,
        onPrimary: backgroundDark,
        surface: surfaceDark,
        onSurface: textDark,
        error: errorDark,
        outlineVariant: mutedDark.withValues(alpha: 0.3),
      );
}
