import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_dimensions.dart';
import 'color_tokens.dart';
import 'typography.dart';

/// Central theme factory adhering strictly to `design-system.md`.
abstract final class AppTheme {
  /// Builds ThemeData for Light appearance.
  static ThemeData light({AccentPreset preset = AccentPreset.violet}) {
    final colors = AppColors.light(preset: preset);
    final typography = AppTypography.standard(
      textColor: colors.textPrimary,
      secondaryColor: colors.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        surface: colors.surface,
        onSurface: colors.textPrimary,
        primary: colors.accent,
        onPrimary: Colors.white,
        error: colors.danger,
        onError: Colors.white,
      ),
      dividerColor: colors.separator,
      dividerTheme: DividerThemeData(
        color: colors.separator,
        thickness: 0.5,
        space: 1.0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusCard,
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
      extensions: [
        colors,
        typography,
      ],
    );
  }

  /// Builds ThemeData for Dark appearance (OLED-friendly canvas + raised charcoal surfaces).
  static ThemeData dark({AccentPreset preset = AccentPreset.violet}) {
    final colors = AppColors.dark(preset: preset);
    final typography = AppTypography.standard(
      textColor: colors.textPrimary,
      secondaryColor: colors.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background, // Pure OLED black #000000
      colorScheme: ColorScheme.dark(
        surface: colors.surface,
        onSurface: colors.textPrimary,
        primary: colors.accent,
        onPrimary: Colors.white,
        error: colors.danger,
        onError: Colors.white,
      ),
      dividerColor: colors.separator,
      dividerTheme: DividerThemeData(
        color: colors.separator,
        thickness: 0.5,
        space: 1.0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusCard,
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
      extensions: [
        colors,
        typography,
      ],
    );
  }
}
