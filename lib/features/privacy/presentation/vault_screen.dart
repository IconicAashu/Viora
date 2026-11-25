import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../core/services/vault_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/formatters.dart';
import '../../../shared/widgets/viora_app_bar.dart';
import '../../../shared/widgets/viora_button.dart';
import '../../../shared/widgets/viora_card.dart';
import '../../../shared/widgets/viora_empty_state.dart';
import '../../../shared/widgets/viora_video_thumbnail.dart';
import '../../player/presentation/video_player_screen.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  bool _isUnlocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _promptUnlock();
  }

  Future<void> _promptUnlock() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final bioService = ref.read(biometricAuthServiceProvider);
      final success = await bioService.authenticate(
        title: 'Unlock Private Vault',
        subtitle: 'Confirm your biometric or device credentials',
      );
      if (mounted) {
        setState(() {
          _isUnlocked = success;
          _isAuthenticating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  void _confirmUnhideVideo(Video video) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Restore to Library?', style: context.typography.title3),
          content: Text(
            'This video will be moved back to device public storage and restored to your main library.',
            style: context.typography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final vault = ref.read(vaultServiceProvider);
                final db = ref.read(appDatabaseProvider);
                final success = await vault.unhideVideo(db, video);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Restored "${video.title}" to library' : 'Failed to restore video',
                      ),
                    ),
                  );
                }
              },
              child: Text('Restore', style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (!_isUnlocked) {
      return Scaffold(
        appBar: VioraAppBar(
          title: 'Private Vault',
          leading: IconButton(
            icon: Icon(VioraIcons.back, color: colors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(VioraIcons.lock, color: colors.warning, size: 36),
                ),
                const SizedBox(height: AppDimensions.space20),
                Text('Vault Locked', style: typography.title2),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Biometric authentication is required to access your hidden videos.',
                  style: typography.subheadline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space24),
                VioraButton(
                  label: 'Unlock Vault',
                  isLoading: _isAuthenticating,
                  icon: const Icon(VioraIcons.biometric, size: 20, color: Colors.white),
                  onPressed: _promptUnlock,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final hiddenVideosAsync = ref.watch(hiddenVideosProvider);

    return Scaffold(
      appBar: VioraAppBar(
        title: 'Private Vault',
        leading: IconButton(
          icon: Icon(VioraIcons.back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(VioraIcons.lock, color: colors.warning),
            onPressed: () => setState(() => _isUnlocked = false),
            tooltip: 'Lock Vault',
          ),
        ],
      ),
      body: hiddenVideosAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colors.danger))),
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: VioraEmptyState(
                icon: VioraIcons.appLock,
                title: 'Vault is Empty',
                description: 'To hide videos from your library and gallery apps, use the 3-dot menu on any video.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.space16),
            itemCount: videos.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
            itemBuilder: (ctx, idx) {
              final video = videos[idx];

              return VioraCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(
                        video: video,
                        playlist: videos,
                        initialIndex: idx,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: VioraVideoThumbnail(
                        video: video,
                        width: 80,
                        height: 50,
                        fit: BoxFit.cover,
                        borderRadius: AppDimensions.borderRadiusCompact,
                        fallbackIconSize: 24.0,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: typography.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${Formatters.formatDuration(video.durationMs)} • ${Formatters.formatFileSize(video.sizeBytes)}',
                            style: typography.footnote,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(VioraIcons.unlock, color: colors.accent, size: 20),
                      tooltip: 'Restore to Library',
                      onPressed: () => _confirmUnhideVideo(video),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
