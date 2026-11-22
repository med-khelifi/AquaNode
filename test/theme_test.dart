import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_node/core/theme/app_theme.dart';

void main() {
  group('Theme System & Extensions', () {
    test('light_theme.dart provides valid light ThemeData with StatusColors', () {
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.primary, AppColors.primaryLight);
      expect(lightTheme.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(lightTheme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);

      final statusColors = lightTheme.extension<StatusColors>();
      expect(statusColors, isNotNull);
      expect(statusColors!.success, AppColors.successLight);
      expect(statusColors.warning, AppColors.warningLight);
      expect(statusColors.error, AppColors.errorLight);
      expect(statusColors.muted, AppColors.mutedLight);
    });

    test('dark_theme.dart provides valid dark ThemeData with StatusColors', () {
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.primary, AppColors.primaryDark);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(darkTheme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);

      final statusColors = darkTheme.extension<StatusColors>();
      expect(statusColors, isNotNull);
      expect(statusColors!.success, AppColors.successDark);
      expect(statusColors.warning, AppColors.warningDark);
      expect(statusColors.error, AppColors.errorDark);
      expect(statusColors.muted, AppColors.mutedDark);
    });

    test('buildTheme resolves to lightTheme and darkTheme correctly', () {
      expect(buildTheme(Brightness.light), lightTheme);
      expect(buildTheme(Brightness.dark), darkTheme);
    });

    test('StatusColors copyWith and lerp operate accurately', () {
      final s1 = StatusColors.light();
      final copied = s1.copyWith(success: Colors.purple);
      expect(copied.success, Colors.purple);
      expect(copied.warning, s1.warning);

      final s2 = StatusColors.dark();
      final lerped = s1.lerp(s2, 0.5);
      expect(lerped, isNotNull);
      expect(lerped.success, Color.lerp(s1.success, s2.success, 0.5));
    });

    test('AppTypography provides clean typography standards', () {
      expect(AppTypography.fontFamily, 'Roboto');
      expect(AppTypography.lightTextTheme.headlineLarge?.color, AppColors.textLight);
      expect(AppTypography.darkTextTheme.headlineLarge?.color, AppColors.textDark);
      expect(AppTypography.lightTextTheme.bodySmall?.color, AppColors.mutedLight);
    });
  });
}
