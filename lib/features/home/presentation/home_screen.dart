import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/permissions/media_permission_service.dart';
import '../../../core/services/video_discovery_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/utilities/motion_utils.dart';
import '../../../shared/widgets/viora_button.dart';
import '../../../shared/widgets/viora_video_thumbnail.dart';
import '../../collections/presentation/collections_screen.dart';
import '../../player/presentation/video_player_screen.dart';
import '../../privacy/presentation/vault_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../settings/presentation/settings_screen.dart';

/// Minimalist, Apple-inspired Home Screen for VIORA.
///
/// Layout hierarchy:
/// 1. Minimal VIORA header with Search and Settings.
/// 2. Continue Watching (conditional — only when saved progress exists).
/// 3. Favorites & Private Vault compact shortcut boxes.
/// 4. Recently Added horizontal 16:9 carousel (hidden when empty).
/// 5. Recently Played horizontal 16:9 carousel (hidden when empty).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateToLibrary,
    this.onNavigateToSettings,
  });

  final VoidCallback onNavigateToLibrary;
  final VoidCallback? onNavigateToSettings;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isScanning = false;

  Future<void> _performScan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    try {
      final permService = ref.read(mediaPermissionServiceProvider);
      final status = await permService.requestVideoPermission();
      if (status.isGranted) {
        final discovery = ref.read(videoDiscoveryServiceProvider);
        final db = ref.read(appDatabaseProvider);
        await discovery.syncWithDatabase(db);
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  void _openPlayer(Video video, List<Video> playlist, int index) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          video: video,
          playlist: playlist,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final allVideosAsync = ref.watch(libraryVideosProvider);
    final continueWatchingAsync = ref.watch(continueWatchingVideosProvider);
    final recentlyAddedAsync = ref.watch(recentlyAddedVideosProvider);
    final recentlyPlayedAsync = ref.watch(recentlyPlayedVideosProvider);
    final favoritesAsync = ref.watch(favoriteVideosProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Minimal Apple Header
            _buildMinimalHeader(context),

            // Scrollable Content
            Expanded(
              child: allVideosAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.accent,
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Failed to load media: $err',
                      style: typography.subheadline.copyWith(color: colors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (allVideos) {
                  // Peaceful Minimal Empty State when library is empty
                  if (allVideos.isEmpty) {
                    return _buildMinimalEmptyState(context);
                  }

                  final continueVideos = continueWatchingAsync.value ?? [];
                  final recentAdded = recentlyAddedAsync.value ?? [];
                  final recentPlayed = recentlyPlayedAsync.value ?? [];
                  final favVideos = favoritesAsync.value ?? [];

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.space16,
                      AppDimensions.space8,
                      AppDimensions.space16,
                      AppDimensions.bottomNavBarHeight + AppDimensions.space20,
                    ),
                    children: [
                      // 2. Continue Watching (Conditional — ONLY if saved progress exists)
                      if (continueVideos.isNotEmpty) ...[
                        _buildContinueWatchingSection(context, continueVideos),
                        const SizedBox(height: AppDimensions.space20),
                      ],

                      // 3. Favorites & Private Vault compact shortcut boxes
                      _buildQuickAccessSection(context, favVideos),

                      // 4. Recently Added (Hidden when empty)
                      if (recentAdded.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space20),
                        _VideoCarouselSection(
                          title: 'Recently Added',
                          videos: recentAdded,
                          onSeeAll: () {
                            HapticFeedback.selectionClick();
                            widget.onNavigateToLibrary();
                          },
                          onVideoTap: (video, idx) => _openPlayer(video, recentAdded, idx),
                          subtitleBuilder: (video) =>
                              (video.resolution != null && video.resolution!.isNotEmpty)
                                  ? video.resolution!
                                  : Formatters.formatFileSize(video.sizeBytes),
                        ),
                      ],

                      // 5. Recently Played (Hidden when playback history is empty)
                      if (recentPlayed.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space20),
                        _VideoCarouselSection(
                          title: 'Recently Played',
                          videos: recentPlayed,
                          onSeeAll: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CollectionDetailScreen(
                                  title: 'Recently Played',
                                  icon: VioraIcons.recent,
                                  videos: recentPlayed,
                                ),
                              ),
                            );
                          },
                          onVideoTap: (video, idx) => _openPlayer(video, recentPlayed, idx),
                          subtitleBuilder: (video) =>
                              Formatters.formatDuration(video.durationMs),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Minimal Apple Header: Wordmark on left, Search & Settings on right.
  Widget _buildMinimalHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space20,
        AppDimensions.space12,
        AppDimensions.space12,
        AppDimensions.space8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppConstants.appName,
            style: typography.title2.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          _HeaderIconButton(
            icon: VioraIcons.search,
            tooltip: 'Search Videos',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          const SizedBox(width: AppDimensions.space4),
          _HeaderIconButton(
            icon: VioraIcons.settings,
            tooltip: 'Settings',
            onTap: () {
              if (widget.onNavigateToSettings != null) {
                widget.onNavigateToSettings!();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// 2. Continue Watching: Cinematic 16:9 hero card with subtle progress.
  Widget _buildContinueWatchingSection(BuildContext context, List<Video> videos) {
    final colors = context.colors;
    final typography = context.typography;
    final latest = videos.first;

    final progress = latest.durationMs > 0
        ? (latest.lastPlayedPositionMs / latest.durationMs).clamp(0.0, 1.0)
        : 0.0;
    final remainingMs = (latest.durationMs - latest.lastPlayedPositionMs).clamp(0, latest.durationMs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space12),
          child: Text(
            'Continue Watching',
            style: typography.headline.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        _SpringInteractiveCard(
          onTap: () => _openPlayer(latest, videos, 0),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: colors.separator.withValues(alpha: context.isDark ? 0.35 : 0.65),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.isDark
                      ? const Color(0x33000000)
                      : const Color(0x0C000000),
                  blurRadius: 16.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VioraVideoThumbnail(
                        video: latest,
                        fit: BoxFit.cover,
                        fallbackIconSize: 44.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                            stops: const [0.55, 1.0],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(
                            VioraIcons.play,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${Formatters.formatDuration(remainingMs)} left',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colors.surfaceSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  minHeight: 2.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                    vertical: AppDimensions.space12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              latest.title,
                              style: typography.headline.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Resumed at ${Formatters.formatDuration(latest.lastPlayedPositionMs)} • Total ${Formatters.formatDuration(latest.durationMs)}',
                              style: typography.footnote.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Icon(
                        VioraIcons.chevronRight,
                        size: 16,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 3. Quick Access: Compact dual-tile row for Favorites & Vault.
  Widget _buildQuickAccessSection(BuildContext context, List<Video> favVideos) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      children: [
        Expanded(
          child: _SpringInteractiveCard(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CollectionDetailScreen(
                    title: 'Favorites',
                    icon: VioraIcons.favorites,
                    videos: favVideos,
                  ),
                ),
              );
            },
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: colors.separator.withValues(alpha: context.isDark ? 0.35 : 0.65),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.danger.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      VioraIcons.favorites,
                      color: colors.danger,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Favorites',
                      style: typography.subheadline.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${favVideos.length}',
                    style: typography.footnote.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: _SpringInteractiveCard(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultScreen()),
              );
            },
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: colors.separator.withValues(alpha: context.isDark ? 0.35 : 0.65),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      VioraIcons.lock,
                      color: colors.warning,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'Vault',
                      style: typography.subheadline.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    VioraIcons.chevronRight,
                    color: colors.textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Minimal Empty State when no videos exist on the device.
  Widget _buildMinimalEmptyState(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.separator.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Icon(
                VioraIcons.video,
                size: 34,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
            Text(
              'Your Library is Empty',
              style: typography.title2.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Videos stored on your device will appear here.',
              style: typography.subheadline.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space24),
            VioraButton(
              label: 'Scan Videos',
              icon: const Icon(VioraIcons.scan, size: 18, color: Colors.white),
              isLoading: _isScanning,
              onPressed: _performScan,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared horizontal 16:9 video carousel section used for Recently Added and Recently Played.
class _VideoCarouselSection extends StatelessWidget {
  const _VideoCarouselSection({
    required this.title,
    required this.videos,
    required this.onSeeAll,
    required this.onVideoTap,
    required this.subtitleBuilder,
  });

  final String title;
  final List<Video> videos;
  final VoidCallback onSeeAll;
  final void Function(Video video, int index) onVideoTap;
  final String Function(Video video) subtitleBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: typography.headline.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                child: Text(
                  'See All',
                  style: typography.subheadline.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),
        SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: videos.length.clamp(0, 15),
            separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.space12),
            itemBuilder: (ctx, idx) {
              final video = videos[idx];

              return _SpringInteractiveCard(
                onTap: () => onVideoTap(video, idx),
                child: SizedBox(
                  width: 172,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: colors.separator.withValues(alpha: context.isDark ? 0.35 : 0.65),
                              width: 0.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              VioraVideoThumbnail(
                                video: video,
                                fit: BoxFit.cover,
                                fallbackIconSize: 26.0,
                              ),
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    Formatters.formatDuration(video.durationMs),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        video.title,
                        style: typography.subheadline.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitleBuilder(video),
                        style: typography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Minimal Header Icon Button with 44pt touch target and tactile press feedback.
class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isReduced = MotionUtils.isReduceMotionEnabled(context);
    final colors = context.colors;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: (_isPressed && !isReduced) ? 0.92 : 1.0,
          duration: isReduced ? Duration.zero : MotionUtils.durationFast,
          curve: MotionUtils.standardCurve,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 22,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Spring Interactive Card: Direct manipulation press-down feedback (`scale: 0.98`)
/// adhering to WWDC fluid interface principles.
class _SpringInteractiveCard extends StatefulWidget {
  const _SpringInteractiveCard({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_SpringInteractiveCard> createState() => _SpringInteractiveCardState();
}

class _SpringInteractiveCardState extends State<_SpringInteractiveCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isReduced = MotionUtils.isReduceMotionEnabled(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: (_isPressed && !isReduced) ? 0.98 : 1.0,
        duration: isReduced ? Duration.zero : MotionUtils.durationFast,
        curve: MotionUtils.standardCurve,
        child: widget.child,
      ),
    );
  }
}
