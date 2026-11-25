import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/video_discovery_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/formatters.dart';
import '../../../shared/widgets/viora_card.dart';
import '../../../shared/widgets/viora_empty_state.dart';
import '../../../shared/widgets/viora_video_thumbnail.dart';
import '../../player/presentation/video_player_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _queryController.addListener(() {
      setState(() {
        _searchQuery = _queryController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final allVideosAsync = ref.watch(libraryVideosProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // iOS Style Search Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(VioraIcons.back, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: AppDimensions.borderRadiusCompact,
                      ),
                      child: TextField(
                        controller: _queryController,
                        autofocus: true,
                        style: typography.body,
                        decoration: InputDecoration(
                          hintText: 'Search videos, folders...',
                          hintStyle: typography.body.copyWith(color: colors.textTertiary),
                          prefixIcon: Icon(VioraIcons.search, size: 18, color: colors.textTertiary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(VioraIcons.close, size: 16, color: colors.textSecondary),
                                  onPressed: () => _queryController.clear(),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Search Results Body
            Expanded(
              child: allVideosAsync.when(
                loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
                error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colors.danger))),
                data: (allVideos) {
                  if (_searchQuery.isEmpty) {
                    return const Center(
                      child: VioraEmptyState(
                        icon: VioraIcons.search,
                        title: 'Search Video Library',
                        description: 'Find any video by title, keyword, or folder location.',
                      ),
                    );
                  }

                  final results = allVideos.where((v) {
                    final titleMatch = v.title.toLowerCase().contains(_searchQuery);
                    final pathMatch = v.filePath.toLowerCase().contains(_searchQuery);
                    return titleMatch || pathMatch;
                  }).toList();

                  if (results.isEmpty) {
                    return Center(
                      child: VioraEmptyState(
                        icon: VioraIcons.search,
                        title: 'No Matching Videos',
                        description: 'No videos found matching "$_searchQuery".',
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
                    itemBuilder: (ctx, idx) {
                      final video = results[idx];

                      return VioraCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerScreen(
                                video: video,
                                playlist: results,
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
                            Icon(VioraIcons.play, color: colors.accent, size: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
