import 'package:flutter/material.dart';
import 'motion_utils.dart';

/// Custom page route with Apple-inspired smooth slide and fade transitions,
/// strictly respecting the user's Reduce Motion preference.
class VioraPageRoute<T> extends PageRouteBuilder<T> {
  VioraPageRoute({
    required Widget page,
    super.settings,
    this.transitionType = VioraPageTransitionType.slideFromRight,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final isReducedMotion = MotionUtils.isReduceMotionEnabled(context);
            if (isReducedMotion) {
              return child;
            }

            switch (transitionType) {
              case VioraPageTransitionType.slideFromRight:
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.08, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );

                final fadeAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                );

                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  ),
                );

              case VioraPageTransitionType.slideFromBottom:
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.12),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );

                final fadeAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                );

                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  ),
                );

              case VioraPageTransitionType.fade:
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                  child: child,
                );
            }
          },
        );

  final VioraPageTransitionType transitionType;
}

enum VioraPageTransitionType {
  slideFromRight,
  slideFromBottom,
  fade,
}
