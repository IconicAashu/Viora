import 'package:flutter/material.dart';

/// Typography scale implementing `design-system.md`.
/// Features natural line heights (~1.2 - 1.45x) and semantic hierarchies.
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.largeTitle,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.headline,
    required this.body,
    required this.callout,
    required this.subheadline,
    required this.footnote,
    required this.caption,
  });

  final TextStyle largeTitle;
  final TextStyle title1;
  final TextStyle title2;
  final TextStyle title3;
  final TextStyle headline;
  final TextStyle body;
  final TextStyle callout;
  final TextStyle subheadline;
  final TextStyle footnote;
  final TextStyle caption;

  factory AppTypography.standard({required Color textColor, required Color secondaryColor}) {
    return AppTypography(
      largeTitle: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w700,
        height: 1.20,
        letterSpacing: 0.37,
        color: textColor,
      ),
      title1: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0.36,
        color: textColor,
      ),
      title2: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        height: 1.27,
        letterSpacing: 0.35,
        color: textColor,
      ),
      title3: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        height: 1.30,
        letterSpacing: 0.38,
        color: textColor,
      ),
      headline: TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.41,
        color: textColor,
      ),
      body: TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w400,
        height: 1.35,
        letterSpacing: -0.41,
        color: textColor,
      ),
      callout: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.37,
        letterSpacing: -0.32,
        color: textColor,
      ),
      subheadline: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        height: 1.40,
        letterSpacing: -0.24,
        color: secondaryColor,
      ),
      footnote: TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        height: 1.42,
        letterSpacing: -0.08,
        color: secondaryColor,
      ),
      caption: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.0,
        color: secondaryColor,
      ),
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? largeTitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? headline,
    TextStyle? body,
    TextStyle? callout,
    TextStyle? subheadline,
    TextStyle? footnote,
    TextStyle? caption,
  }) {
    return AppTypography(
      largeTitle: largeTitle ?? this.largeTitle,
      title1: title1 ?? this.title1,
      title2: title2 ?? this.title2,
      title3: title3 ?? this.title3,
      headline: headline ?? this.headline,
      body: body ?? this.body,
      callout: callout ?? this.callout,
      subheadline: subheadline ?? this.subheadline,
      footnote: footnote ?? this.footnote,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      largeTitle: TextStyle.lerp(largeTitle, other.largeTitle, t)!,
      title1: TextStyle.lerp(title1, other.title1, t)!,
      title2: TextStyle.lerp(title2, other.title2, t)!,
      title3: TextStyle.lerp(title3, other.title3, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      callout: TextStyle.lerp(callout, other.callout, t)!,
      subheadline: TextStyle.lerp(subheadline, other.subheadline, t)!,
      footnote: TextStyle.lerp(footnote, other.footnote, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}
