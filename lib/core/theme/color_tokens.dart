import 'package:flutter/material.dart';

/// Available accent color presets in VIORA.
/// Default preset is Violet as specified in the product requirements.
enum AccentPreset {
  violet(
    label: 'Violet',
    lightAccent: Color(0xFFAF52DE),
    darkAccent: Color(0xFFBF5AF2),
  ),
  blue(
    label: 'Blue',
    lightAccent: Color(0xFF007AFF),
    darkAccent: Color(0xFF0A84FF),
  ),
  teal(
    label: 'Teal',
    lightAccent: Color(0xFF30B0C7),
    darkAccent: Color(0xFF64D2FF),
  ),
  green(
    label: 'Green',
    lightAccent: Color(0xFF34C759),
    darkAccent: Color(0xFF30D158),
  ),
  orange(
    label: 'Orange',
    lightAccent: Color(0xFFFF9500),
    darkAccent: Color(0xFFFF9F0A),
  );

  const AccentPreset({
    required this.label,
    required this.lightAccent,
    required this.darkAccent,
  });

  final String label;
  final Color lightAccent;
  final Color darkAccent;

  Color accentFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkAccent : lightAccent;
  }
}

/// Semantic color tokens strictly mapping `design-system.md`.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.separator,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color separator;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;

  /// Default Light semantic token palette (Table from design-system.md)
  static AppColors light({AccentPreset preset = AccentPreset.violet}) {
    return AppColors(
      background: const Color(0xFFF2F2F7),
      surface: const Color(0xFFFFFFFF),
      surfaceSecondary: const Color(0xFFF2F2F7),
      textPrimary: const Color(0xFF1C1C1E),
      textSecondary: const Color(0xFF636366),
      textTertiary: const Color(0xFF8E8E93),
      // #3C3C43 at 12% opacity
      separator: const Color(0x1F3C3C43),
      accent: preset.lightAccent,
      success: const Color(0xFF248A3D),
      warning: const Color(0xFF9A6700),
      danger: const Color(0xFFD70015),
    );
  }

  /// Default Dark semantic token palette (Table from design-system.md)
  static AppColors dark({AccentPreset preset = AccentPreset.violet}) {
    return AppColors(
      background: const Color(0xFF000000), // Pure OLED black
      surface: const Color(0xFF1C1C1E),
      surfaceSecondary: const Color(0xFF2C2C2E),
      textPrimary: const Color(0xFFF5F5F7),
      textSecondary: const Color(0xFFAEAEB2),
      textTertiary: const Color(0xFF8E8E93),
      // #545458 at 60% opacity
      separator: const Color(0x99545458),
      accent: preset.darkAccent,
      success: const Color(0xFF30D158),
      warning: const Color(0xFFFFD60A),
      danger: const Color(0xFFFF453A),
    );
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? separator,
    Color? accent,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      separator: separator ?? this.separator,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
