import 'package:flutter/material.dart';
import 'package:aqua_node/core/extensions/theme_context_extension.dart';
import 'package:aqua_node/core/widgets/shimmer.dart';

/// Extension on [Widget] allowing any widget to apply shimmer loading
/// effortlessly adapting to light (white) or dark themes.
extension ShimmerWidgetExtension on Widget {
  /// Wraps this widget in a theme-aware Shimmer animation.
  Widget shimmer(
    BuildContext context, {
    bool enabled = true,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!enabled) return this;
    final colors = context.shimmerColors;
    return Shimmer(
      baseColor: colors.baseColor,
      highlightColor: colors.highlightColor,
      duration: duration,
      child: this,
    );
  }

  /// Conditionally displays a shimmer placeholder while [isLoading] is true.
  Widget shimmerLoading({
    required BuildContext context,
    required bool isLoading,
    Widget Function()? placeholder,
  }) {
    if (!isLoading) return this;
    if (placeholder != null) {
      return placeholder().shimmer(context);
    }
    return shimmer(context);
  }
}

/// Extension on [BuildContext] providing clean access to shimmer colors,
/// theme state, and placeholder builders.
extension ShimmerContextExtension on BuildContext {
  /// True if current theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Creates a [ShimmerBox] placeholder styled with the current theme shimmer base.
  Widget shimmerBox({
    double? width,
    double? height,
    double borderRadius = 8,
    ShapeBorder? shape,
  }) =>
      ShimmerBox(
        width: width,
        height: height,
        borderRadius: borderRadius,
        shape: shape,
      );

  /// Creates a theme-aware shimmering card container.
  Widget shimmerCard({
    double? width,
    double? height,
    double borderRadius = 16,
    Widget? child,
  }) =>
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(16),
          child: child ??
              ShimmerBox(
                width: width,
                height: height,
                borderRadius: borderRadius,
              ),
        ),
      ).shimmer(this);
}
