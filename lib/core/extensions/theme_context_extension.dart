import 'package:flutter/material.dart';
import 'package:aqua_node/core/theme/extensions/status_colors.dart';

/// Convenient theme access shortcuts on [BuildContext].
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>()!;
}
