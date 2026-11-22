import 'package:flutter/material.dart';
import 'package:aqua_node/core/theme/dark_theme.dart';
import 'package:aqua_node/core/theme/light_theme.dart';

export 'package:aqua_node/core/theme/app_colors.dart';
export 'package:aqua_node/core/theme/app_typography.dart';
export 'package:aqua_node/core/theme/dark_theme.dart';
export 'package:aqua_node/core/theme/light_theme.dart';
export 'package:aqua_node/core/theme/extensions/status_colors.dart';
export 'package:aqua_node/core/theme/extensions/shimmer_colors.dart';
export 'package:aqua_node/core/extensions/theme_context_extension.dart';
export 'package:aqua_node/core/extensions/shimmer_extension.dart';
export 'package:aqua_node/core/widgets/shimmer.dart';

/// Backward-compatible builder matching the original function signature.
ThemeData buildTheme(Brightness brightness) =>
    brightness == Brightness.dark ? darkTheme : lightTheme;
