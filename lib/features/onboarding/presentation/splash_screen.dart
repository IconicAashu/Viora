import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utilities/viora_page_route.dart';
import '../../main_scaffold.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    // Subtle scale from 0.95 to 1.0 per Phase 1 design specifications
    _logoScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // If Reduce Motion is enabled, complete animations immediately
    final isReducedMotion = ref.read(reduceMotionProvider);
    if (isReducedMotion) {
      _logoController.value = 1.0;
      _textController.value = 1.0;
      await _checkNextScreen(immediate: true);
      return;
    }

    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _textController.forward();

    await _checkNextScreen(immediate: false);
  }

  Future<void> _checkNextScreen({required bool immediate}) async {
    if (!immediate) {
      // Total display time approximately 1.2 seconds, without delaying startup
      await Future.delayed(const Duration(milliseconds: 1100));
    }
    if (!mounted) return;

    try {
      final db = ref.read(appDatabaseProvider);
      final pref = await (db.select(db.userPreferences)
            ..where((tbl) => tbl.key.equals('has_completed_onboarding')))
          .getSingleOrNull();

      final hasCompleted = pref?.value == 'true';

      if (!mounted) return;
      final targetScreen = hasCompleted ? const MainScaffold() : const OnboardingScreen();

      Navigator.of(context).pushReplacement(
        VioraPageRoute(
          page: targetScreen,
          transitionType: VioraPageTransitionType.fade,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle ambient radial glow behind logo
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    colors.accent.withValues(alpha: isDark ? 0.08 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Staggered animated logo, wordmark, and tagline
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 96.0,
                      height: 96.0,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: typography.title1.copyWith(
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          AppConstants.appTagline,
                          style: typography.subheadline.copyWith(
                            color: colors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
