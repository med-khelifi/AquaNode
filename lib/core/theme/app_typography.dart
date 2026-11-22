import 'package:flutter/material.dart';
import 'package:aqua_node/core/theme/app_colors.dart';

/// Centralized typography and text styles for Aqua Node.
abstract final class AppTypography {
  static const String fontFamily = 'Roboto';

  // Base Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  // Base Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // Base Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Base Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Base Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static TextTheme _buildTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
  }) =>
      TextTheme(
        displayLarge: displayLarge.copyWith(color: primaryColor),
        displayMedium: displayMedium.copyWith(color: primaryColor),
        displaySmall: displaySmall.copyWith(color: primaryColor),
        headlineLarge: headlineLarge.copyWith(color: primaryColor),
        headlineMedium: headlineMedium.copyWith(color: primaryColor),
        headlineSmall: headlineSmall.copyWith(color: primaryColor),
        titleLarge: titleLarge.copyWith(color: primaryColor),
        titleMedium: titleMedium.copyWith(color: primaryColor),
        titleSmall: titleSmall.copyWith(color: primaryColor),
        bodyLarge: bodyLarge.copyWith(color: primaryColor),
        bodyMedium: bodyMedium.copyWith(color: primaryColor),
        bodySmall: bodySmall.copyWith(color: secondaryColor),
        labelLarge: labelLarge.copyWith(color: primaryColor),
        labelMedium: labelMedium.copyWith(color: primaryColor),
        labelSmall: labelSmall.copyWith(color: secondaryColor),
      );

  /// Light theme typography
  static final TextTheme lightTextTheme = _buildTextTheme(
    primaryColor: AppColors.textLight,
    secondaryColor: AppColors.mutedLight,
  );

  /// Dark theme typography
  static final TextTheme darkTextTheme = _buildTextTheme(
    primaryColor: AppColors.textDark,
    secondaryColor: AppColors.mutedDark,
  );
}
