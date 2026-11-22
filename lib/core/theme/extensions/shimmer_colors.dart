import 'package:flutter/material.dart';

/// Semantic shimmer colors extension for [ThemeData] supporting white (light) and dark themes.
@immutable
class ShimmerColors extends ThemeExtension<ShimmerColors> {
  final Color baseColor;
  final Color highlightColor;

  const ShimmerColors({
    required this.baseColor,
    required this.highlightColor,
  });

  /// Shimmer colors for White (Light) Theme
  factory ShimmerColors.light() => const ShimmerColors(
        baseColor: Color(0xFFE2E8F0),      // Crisp slate-200
        highlightColor: Color(0xFFF8FAFC),  // Luminous white highlight
      );

  /// Shimmer colors for Dark Theme
  factory ShimmerColors.dark() => const ShimmerColors(
        baseColor: Color(0xFF16243A),      // Deep slate surface
        highlightColor: Color(0xFF243653),  // Translucent glowing slate highlight
      );

  @override
  ShimmerColors copyWith({
    Color? baseColor,
    Color? highlightColor,
  }) =>
      ShimmerColors(
        baseColor: baseColor ?? this.baseColor,
        highlightColor: highlightColor ?? this.highlightColor,
      );

  @override
  ShimmerColors lerp(ThemeExtension<ShimmerColors>? other, double t) {
    if (other is! ShimmerColors) return this;
    return ShimmerColors(
      baseColor: Color.lerp(baseColor, other.baseColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
    );
  }
}
