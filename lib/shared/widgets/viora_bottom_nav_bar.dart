import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utilities/motion_utils.dart';
import '../models/nav_destination.dart';

/// iOS-Inspired Expanding Bottom Navigation Bar.
///
/// Strict Design Rules (Step 4 of Apple Designer Redesign):
/// - Show ICONS ONLY. Absolutely NO text labels.
/// - Active icon expands smoothly inside an animated capsule pill container.
/// - Inactive icons remain compact and uncrowded.
/// - Fluid spring animation (damping 1.0, response 0.3-0.4s) when switching tabs.
/// - Frosted glass translucent material (BackdropFilter blur + subtle border + depth shadow).
/// - Tactile haptic feedback on tab change.
class VioraBottomNavBar extends StatelessWidget {
  const VioraBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isReducedMotion = MotionUtils.isReduceMotionEnabled(context);
    final isDark = context.isDark;

    final duration = isReducedMotion ? Duration.zero : MotionUtils.durationStandard;
    const curve = MotionUtils.standardCurve;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.bottomNavBarFloatingMargin,
          right: AppDimensions.bottomNavBarFloatingMargin,
          bottom: AppDimensions.space12,
        ),
        child: Container(
          height: 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x77000000) : const Color(0x18000000),
                blurRadius: 24.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color.fromRGBO(24, 24, 28, 0.82)
                      : const Color.fromRGBO(255, 255, 255, 0.85),
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: isDark
                        ? const Color.fromRGBO(255, 255, 255, 0.14)
                        : const Color.fromRGBO(0, 0, 0, 0.08),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(NavDestination.values.length, (index) {
                    final destination = NavDestination.values[index];
                    final isSelected = index == currentIndex;

                    return Semantics(
                      label: destination.label,
                      selected: isSelected,
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (currentIndex != index) {
                            HapticFeedback.selectionClick();
                            onTap(index);
                          }
                        },
                        child: AnimatedContainer(
                          duration: duration,
                          curve: curve,
                          // Active icon expands into a wide pill container (width ~ 68px)
                          // Inactive icons remain compact (width ~ 46px)
                          width: isSelected ? 72.0 : 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.accent.withValues(alpha: isDark ? 0.22 : 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24.0),
                            border: isSelected
                                ? Border.all(
                                    color: colors.accent.withValues(alpha: 0.28),
                                    width: 0.5,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: AnimatedScale(
                              scale: isSelected && !isReducedMotion ? 1.15 : 1.0,
                              duration: duration,
                              curve: MotionUtils.springBouncy,
                              child: Icon(
                                isSelected ? destination.activeIcon : destination.icon,
                                size: 24.0,
                                color: isSelected
                                    ? colors.accent
                                    : (isDark
                                        ? const Color(0xFFE5E5EA)
                                        : const Color(0xFF1C1C1E)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
