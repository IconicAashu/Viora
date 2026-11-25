import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'typography.dart';

/// Ergonomic syntax sugar for accessing semantic theme tokens anywhere in the widget tree.
extension ThemeExtensions on BuildContext {
  /// Semantic color tokens defined in `design-system.md`.
  AppColors get colors {
    final colors = Theme.of(this).extension<AppColors>();
    assert(colors != null, 'AppColors extension is missing in current ThemeData');
    return colors ?? AppColors.dark();
  }

  /// Typography scale defined in `design-system.md`.
  AppTypography get typography {
    final typography = Theme.of(this).extension<AppTypography>();
    assert(typography != null, 'AppTypography extension is missing in current ThemeData');
    return typography ?? AppTypography.standard(textColor: Colors.white, secondaryColor: Colors.white70);
  }

  /// Current brightness.
  Brightness get brightness => Theme.of(this).brightness;

  /// True if current appearance is dark mode.
  bool get isDark => brightness == Brightness.dark;
}
