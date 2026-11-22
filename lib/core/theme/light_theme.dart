import 'package:flutter/material.dart';
import 'package:aqua_node/core/theme/app_colors.dart';
import 'package:aqua_node/core/theme/app_typography.dart';
import 'package:aqua_node/core/theme/extensions/shimmer_colors.dart';
import 'package:aqua_node/core/theme/extensions/status_colors.dart';

/// Light (White) Theme for Aqua Node built from [AppColors].
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: AppColors.lightColorScheme,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  fontFamily: AppTypography.fontFamily,
  textTheme: AppTypography.lightTextTheme,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    foregroundColor: AppColors.textLight,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceLight,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppColors.mutedLight.withValues(alpha: 0.2),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.mutedLight.withValues(alpha: 0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.mutedLight.withValues(alpha: 0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primaryLight,
        width: 1.5,
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.mutedLight.withValues(alpha: 0.15),
    thickness: 1,
    space: 1,
  ),
  extensions: [
    StatusColors.light(),
    ShimmerColors.light(),
  ],
);
