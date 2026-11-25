import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/permissions/media_permission_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../shared/widgets/viora_button.dart';
import '../../../shared/widgets/viora_logo.dart';
import '../../main_scaffold.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _isLoading = false;

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.into(db.userPreferences).insertOnConflictUpdate(
            UserPreferencesCompanion.insert(
              key: 'has_completed_onboarding',
              value: 'true',
              updatedAt: DateTime.now(),
            ),
          );

      final permService = ref.read(mediaPermissionServiceProvider);
      await permService.requestVideoPermission();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, _, _) => const MainScaffold(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo & Brand Header
              const VioraLogo(
                size: 88.0,
                showWordmark: true,
                showTagline: true,
                heroTag: 'viora_hero_logo',
              ),

              const Spacer(flex: 2),

              // Value Propositions
              _buildFeatureRow(
                icon: VioraIcons.play,
                accentColor: colors.accent,
                title: 'Media3 Cinema Playback',
                description:
                    'Hardware-accelerated rendering, accurate seeking, and intuitive swipe gestures.',
              ),
              const SizedBox(height: AppDimensions.space24),

              _buildFeatureRow(
                icon: VioraIcons.security,
                accentColor: colors.success,
                title: '100% Private & Offline',
                description:
                    'Your media stays on your device. Zero analytics, no trackers, and no accounts.',
              ),
              const SizedBox(height: AppDimensions.space24),

              _buildFeatureRow(
                icon: VioraIcons.collections,
                accentColor: colors.warning,
                title: 'Smart Collections & Vault',
                description:
                    'Organize playlists and secure sensitive clips with biometric app lock.',
              ),

              const Spacer(flex: 3),

              // Continue Action Button
              VioraButton(
                label: 'Get Started',
                isFullWidth: true,
                isLoading: _isLoading,
                onPressed: _completeOnboarding,
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: AppDimensions.borderRadiusCompact,
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        const SizedBox(width: AppDimensions.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.headline),
              const SizedBox(height: 2),
              Text(
                description,
                style: typography.subheadline.copyWith(
                  color: colors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
