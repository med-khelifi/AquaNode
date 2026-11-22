import 'package:flutter/material.dart';
import 'package:aqua_node/core/theme/app_colors.dart';

/// Semantic status colors extension for [ThemeData].
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color success;
  final Color warning;
  final Color error;
  final Color muted;
  final Color neutral;

  const StatusColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.muted,
    required this.neutral,
  });

  /// Status colors for Light (White) Theme
  factory StatusColors.light() => const StatusColors(
        success: AppColors.successLight,
        warning: AppColors.warningLight,
        error: AppColors.errorLight,
        muted: AppColors.mutedLight,
        neutral: AppColors.neutralLight,
      );

  /// Status colors for Dark Theme
  factory StatusColors.dark() => const StatusColors(
        success: AppColors.successDark,
        warning: AppColors.warningDark,
        error: AppColors.errorDark,
        muted: AppColors.mutedDark,
        neutral: AppColors.neutralDark,
      );

  @override
  StatusColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? muted,
    Color? neutral,
  }) =>
      StatusColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
        muted: muted ?? this.muted,
        neutral: neutral ?? this.neutral,
      );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}

