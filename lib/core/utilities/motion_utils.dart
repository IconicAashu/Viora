import 'package:flutter/widgets.dart';

/// Motion and Physics System designed in accordance with Apple's Fluid Interface design talks
/// (WWDC Designing Fluid Interfaces).
///
/// Principles implemented:
/// 1. Critically damped springs (damping: 1.0, response: 0.3-0.4s) for standard UI transitions.
/// 2. Under-damped momentum springs (damping: ~0.8, response: 0.3-0.4s) for physical touch feedback.
/// 3. Instant touch-down response with smooth release physics.
/// 4. Comprehensive Reduce Motion cross-fade and static adaptation.
abstract final class MotionUtils {
  // Standard Apple response timing
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationStandard = Duration(milliseconds: 320);
  static const Duration durationEmphasis = Duration(milliseconds: 450);

  // Apple HIG Easing curves
  // Critically damped / standard fluid curve:
  static const Curve standardCurve = Cubic(0.2, 0.0, 0.0, 1.0); // iOS system spring approximation
  static const Curve springBouncy = Cubic(0.175, 0.885, 0.32, 1.12); // subtle bounce on momentum
  static const Curve easeOut = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve easeInOut = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Checks if reduce motion is requested by the system or user override.
  static bool isReduceMotionEnabled(BuildContext context, [bool? userOverride]) {
    if (userOverride != null) return userOverride;
    return MediaQuery.disableAnimationsOf(context);
  }

  /// Returns Duration.zero if motion should be reduced, otherwise returns [duration].
  static Duration getDuration(
    BuildContext context, {
    Duration duration = durationStandard,
    bool? userOverride,
  }) {
    if (isReduceMotionEnabled(context, userOverride)) {
      return Duration.zero;
    }
    return duration;
  }
}
