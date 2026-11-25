import 'package:flutter/widgets.dart';

/// Layout, spacing, and radius dimension tokens following `design-system.md`.
/// Based on a strict 4 pt base unit scale.
abstract final class AppDimensions {
  // Spacing steps (4 pt base unit)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Screen insets
  static const double screenInsetCompact = 16.0;
  static const double screenInsetWide = 24.0;

  // Interactive target minimum hit area
  static const double minTouchTarget = 44.0;

  // Corner radii scale
  static const double radiusCompact = 8.0;   // Compact controls, tags
  static const double radiusButton = 12.0;    // Buttons, text fields
  static const double radiusCard = 16.0;      // Cards, grouped surfaces
  static const double radiusSheet = 24.0;     // Sheets, bottom nav, dialogs
  static const double radiusPill = 999.0;     // Full capsule buttons, pill tags

  // Common BorderRadii
  static const BorderRadius borderRadiusCompact = BorderRadius.all(Radius.circular(radiusCompact));
  static const BorderRadius borderRadiusButton = BorderRadius.all(Radius.circular(radiusButton));
  static const BorderRadius borderRadiusCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderRadiusSheet = BorderRadius.all(Radius.circular(radiusSheet));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(radiusPill));

  // Common Insets
  static const EdgeInsets edgeInsetsScreen = EdgeInsets.symmetric(horizontal: screenInsetCompact);
  static const EdgeInsets edgeInsetsCard = EdgeInsets.all(space16);
  static const EdgeInsets edgeInsetsButton = EdgeInsets.symmetric(horizontal: space16, vertical: space12);

  // Icon sizing scale
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;

  // Navigation Bar Dimensions
  static const double bottomNavBarHeight = 64.0;
  static const double bottomNavBarFloatingMargin = 16.0;
}
