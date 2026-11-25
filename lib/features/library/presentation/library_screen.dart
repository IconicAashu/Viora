import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/permissions/media_permission_service.dart';
import '../../../core/services/vault_service.dart';
import '../../../core/services/video_discovery_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/formatters.dart';
import '../../../shared/widgets/viora_app_bar.dart';
import '../../../shared/widgets/viora_button.dart';
import '../../../shared/widgets/viora_card.dart';
import '../../../shared/widgets/viora_empty_state.dart';
import '../../../shared/widgets/viora_video_thumbnail.dart';
import '../../player/presentation/video_player_screen.dart';

enum VideoSortOption {
  dateModifiedDesc('Newest First'),
  dateModifiedAsc('Oldest First'),
  titleAsc('Title (A-Z)'),
  titleDesc('Title (Z-A)'),
  durationDesc('Longest First'),
  durationAsc('Shortest First'),
  sizeDesc('Largest First');

  const VideoSortOption(this.label);
  final String label;
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _selectedTabIndex = 0; // 0 = All Videos, 1 = Folders
  bool _isGridView = true;
  bool _isScanning = false;
  VideoSortOption _sortOption = VideoSortOption.dateModifiedDesc;

  @override
  void initState() {
    super.initState();
    _triggerInitialScanIfEmpty();
  }

  Future<void> _triggerInitialScanIfEmpty() async {
    final permService = ref.read(mediaPermissionServiceProvider);
    final hasPerm = await permService.hasVideoPermission();
    if (hasPerm) {
      final db = ref.read(appDatabaseProvider);
      final count = await (db.selectOnly(db.videos)..addColumns([db.videos.id.count()])).map((row) => row.read(db.videos.id.count())).getSingle();
      if ((count ?? 0) == 0) {
        _performScan();
      }
    }
  }

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

  List<Video> _sortVideos(List<Video> videos) {
    final list = List<Video>.from(videos);
    switch (_sortOption) {
      case VideoSortOption.dateModifiedDesc:
        list.sort((a, b) => b.dateModified.compareTo(a.dateModified));
        break;
      case VideoSortOption.dateModifiedAsc:
        list.sort((a, b) => a.dateModified.compareTo(b.dateModified));
        break;
      case VideoSortOption.titleAsc:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case VideoSortOption.titleDesc:
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case VideoSortOption.durationDesc:
        list.sort((a, b) => b.durationMs.compareTo(a.durationMs));
        break;
      case VideoSortOption.durationAsc:
        list.sort((a, b) => a.durationMs.compareTo(b.durationMs));
        break;
      case VideoSortOption.sizeDesc:
        list.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
    }
    return list;
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusSheet)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space8),
                    child: Text('Sort Videos By', style: context.typography.title3),
                  ),
                  const Divider(),
                  ...VideoSortOption.values.map((option) {
                    final isSelected = option == _sortOption;
                    return ListTile(
                      title: Text(
                        option.label,
                        style: context.typography.body.copyWith(
                          color: isSelected ? context.colors.accent : context.colors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected ? Icon(VioraIcons.check, color: context.colors.accent, size: 20) : null,
                      onTap: () {
                        setState(() => _sortOption = option);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVideoOptionsBottomSheet(Video video) {
    final colors = context.colors;
    final typography = context.typography;
    final db = ref.read(appDatabaseProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusSheet)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space8),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colors.surfaceSecondary,
                            borderRadius: AppDimensions.borderRadiusCompact,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: video.thumbnailPath != null && File(video.thumbnailPath!).existsSync()
                              ? Image.file(File(video.thumbnailPath!), fit: BoxFit.cover)
                              : Icon(VioraIcons.video, color: colors.accent, size: 24),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(video.title, style: typography.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(
                                '${Formatters.formatDuration(video.durationMs)} • ${Formatters.formatFileSize(video.sizeBytes)}',
                                style: typography.footnote,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Play
                  ListTile(
                    leading: Icon(VioraIcons.play, color: colors.accent),
                    title: Text('Play', style: typography.body),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openPlayer(video);
                    },
                  ),

                  // Favorite Toggle
                  ListTile(
                    leading: Icon(
                      VioraIcons.favorites,
                      color: video.isFavorite ? colors.danger : colors.accent,
                    ),
                    title: Text(video.isFavorite ? 'Remove from Favorites' : 'Add to Favorites', style: typography.body),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await (db.update(db.videos)..where((tbl) => tbl.id.equals(video.id))).write(
                        VideosCompanion(isFavorite: Value(!video.isFavorite)),
                      );
                    },
                  ),

                  // Add to Collection
                  ListTile(
                    leading: Icon(VioraIcons.folder, color: colors.accent),
                    title: Text('Add to Collection', style: typography.body),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAddToCollectionDialog(video);
                    },
                  ),

                  // Video Details
                  ListTile(
                    leading: Icon(VioraIcons.info, color: colors.accent),
                    title: Text('Video Details', style: typography.body),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showVideoDetailsDialog(video);
                    },
                  ),

                  // Move to Private Vault
                  ListTile(
                    leading: Icon(VioraIcons.lock, color: colors.warning),
                    title: Text('Move to Private Vault', style: typography.body.copyWith(color: colors.warning)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmHideVideo(video);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddToCollectionDialog(Video video) async {
    final db = ref.read(appDatabaseProvider);
    final collections = await (db.select(db.collections)..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).get();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Add to Collection', style: context.typography.title3),
          content: SizedBox(
            width: double.maxFinite,
            child: collections.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.space16),
                    child: Text('No collections created yet.', style: context.typography.body),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: collections.length,
                    itemBuilder: (c, idx) {
                      final item = collections[idx];
                      return ListTile(
                        leading: Icon(VioraIcons.folder, color: context.colors.accent),
                        title: Text(item.name, style: context.typography.body),
                        onTap: () async {
                          // Add mapping
                          await db.into(db.collectionVideos).insertOnConflictUpdate(
                                CollectionVideosCompanion.insert(
                                  id: '${item.id}_${video.id}',
                                  collectionId: item.id,
                                  videoId: video.id,
                                  addedAt: DateTime.now(),
                                ),
                              );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added to "${item.name}"')),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showCreateCollectionDialog(initialVideo: video);
              },
              child: Text('New Collection', style: TextStyle(color: context.colors.accent)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateCollectionDialog({Video? initialVideo}) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('New Collection', style: context.typography.title3),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: context.typography.body,
            decoration: InputDecoration(
              hintText: 'Collection name',
              hintStyle: context.typography.body.copyWith(color: context.colors.textTertiary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  final db = ref.read(appDatabaseProvider);
                  final colId = 'col_${DateTime.now().millisecondsSinceEpoch}';
                  await db.into(db.collections).insert(
                        CollectionsCompanion.insert(
                          id: colId,
                          name: name,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          coverVideoId: Value(initialVideo?.id),
                        ),
                      );

                  if (initialVideo != null) {
                    await db.into(db.collectionVideos).insert(
                          CollectionVideosCompanion.insert(
                            id: '${colId}_${initialVideo.id}',
                            collectionId: colId,
                            videoId: initialVideo.id,
                            addedAt: DateTime.now(),
                          ),
                        );
                  }

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Created "$name"')),
                    );
                  }
                }
              },
              child: Text('Create', style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showVideoDetailsDialog(Video video) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Video Details', style: context.typography.title3),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Title', video.title),
                _buildDetailRow('File Path', video.filePath),
                _buildDetailRow('Resolution', video.resolution ?? 'Unknown'),
                _buildDetailRow('Duration', Formatters.formatDuration(video.durationMs)),
                _buildDetailRow('File Size', Formatters.formatFileSize(video.sizeBytes)),
                _buildDetailRow('Format', video.mimeType),
                _buildDetailRow('Date Modified', Formatters.formatDate(video.dateModified)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: TextStyle(color: context.colors.accent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.typography.caption.copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: 2),
          SelectableText(value, style: context.typography.body),
        ],
      ),
    );
  }

  void _confirmHideVideo(Video video) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Move to Private Vault?', style: context.typography.title3),
          content: Text(
            'This video will be moved to your secure vault and hidden from your library and system media scanners.',
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
                final success = await vault.hideVideo(db, video);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Moved "${video.title}" to Vault' : 'Failed to move video to Vault',
                      ),
                    ),
                  );
                }
              },
              child: Text('Hide Video', style: TextStyle(color: context.colors.warning, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _openPlayer(Video video, [List<Video>? playlist, int? index]) {
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
    final videosAsync = ref.watch(libraryVideosProvider);

    return Scaffold(
      appBar: VioraAppBar(
        title: 'Library',
        isLargeTitle: true,
        actions: [
          if (_selectedTabIndex == 0) ...[
            IconButton(
              icon: Icon(_isGridView ? VioraIcons.list : VioraIcons.grid, color: colors.textPrimary),
              onPressed: () => setState(() => _isGridView = !_isGridView),
              tooltip: _isGridView ? 'List View' : 'Grid View',
            ),
            IconButton(
              icon: Icon(VioraIcons.sort, color: colors.textPrimary),
              onPressed: _showSortDialog,
              tooltip: 'Sort Videos',
            ),
          ],
          IconButton(
            icon: _isScanning
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent),
                  )
                : Icon(VioraIcons.refresh, color: colors.textPrimary),
            onPressed: _performScan,
            tooltip: 'Rescan Storage',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: AppDimensions.borderRadiusCompact,
              ),
              child: Row(
                children: [
                  _buildTabItem(0, 'All Videos'),
                  _buildTabItem(1, 'Folders'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space12),

          // Content Area
          Expanded(
            child: videosAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
              error: (err, _) => Center(
                child: Text('Error loading library: $err', style: TextStyle(color: colors.danger)),
              ),
              data: (videos) {
                if (videos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
                    child: VioraEmptyState(
                      icon: VioraIcons.video,
                      title: 'No Videos Found',
                      description: 'Scan your device storage to index your offline videos.',
                      action: VioraButton(
                        label: 'Scan Storage',
                        isLoading: _isScanning,
                        icon: const Icon(VioraIcons.scan, size: 18, color: Colors.white),
                        onPressed: _performScan,
                      ),
                    ),
                  );
                }

                if (_selectedTabIndex == 0) {
                  final sorted = _sortVideos(videos);
                  return _isGridView ? _buildGridView(sorted) : _buildListView(sorted);
                } else {
                  return _buildFoldersView(videos);
                }
              },
            ),
          ),
          const SizedBox(height: AppDimensions.bottomNavBarHeight + AppDimensions.space16),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    final colors = context.colors;
    final typography = context.typography;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: AppDimensions.borderRadiusCompact,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: typography.subheadline.copyWith(
              color: isSelected ? colors.textPrimary : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(List<Video> videos) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.84,
        crossAxisSpacing: AppDimensions.space12,
        mainAxisSpacing: AppDimensions.space12,
      ),
      itemCount: videos.length,
      itemBuilder: (ctx, index) {
        final video = videos[index];
        return _buildVideoGridCard(video, videos, index);
      },
    );
  }

  Widget _buildVideoGridCard(Video video, List<Video> playlist, int index) {
    final colors = context.colors;
    final typography = context.typography;

    return VioraCard(
      padding: EdgeInsets.zero,
      onTap: () => _openPlayer(video, playlist, index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail container
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                VioraVideoThumbnail(
                  video: video,
                  fit: BoxFit.cover,
                  fallbackIconSize: 36.0,
                ),

                // Resolution badge (top-left)
                if (video.resolution != null && video.resolution!.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.resolution!,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // Duration badge (bottom-right)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Formatters.formatDuration(video.durationMs),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Favorite icon badge
                if (video.isFavorite)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(VioraIcons.favorites, color: colors.danger, size: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Details row
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: typography.subheadline.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatFileSize(video.sizeBytes),
                        style: typography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showVideoOptionsBottomSheet(video),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(VioraIcons.more, size: 16, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Video> videos) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space8),
      itemCount: videos.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
      itemBuilder: (ctx, index) {
        final video = videos[index];
        return _buildVideoListTile(video, videos, index);
      },
    );
  }

  Widget _buildVideoListTile(Video video, List<Video> playlist, int index) {
    final colors = context.colors;
    final typography = context.typography;

    return VioraCard(
      padding: const EdgeInsets.all(AppDimensions.space8),
      onTap: () => _openPlayer(video, playlist, index),
      child: Row(
        children: [
          // Thumbnail with duration overlay
          Stack(
            children: [
              SizedBox(
                width: 90,
                height: 56,
                child: VioraVideoThumbnail(
                  video: video,
                  width: 90,
                  height: 56,
                  fit: BoxFit.cover,
                  borderRadius: AppDimensions.borderRadiusCompact,
                  fallbackIconSize: 24.0,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    Formatters.formatDuration(video.durationMs),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimensions.space12),

          // Info
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
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (video.resolution != null && video.resolution!.isNotEmpty) ...[
                      Text(video.resolution!, style: typography.footnote.copyWith(color: colors.accent)),
                      Text(' • ', style: typography.footnote),
                    ],
                    Text(Formatters.formatFileSize(video.sizeBytes), style: typography.footnote),
                    if (video.isFavorite) ...[
                      const SizedBox(width: 6),
                      Icon(VioraIcons.favorites, color: colors.danger, size: 12),
                    ],
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(VioraIcons.more, size: 18, color: colors.textSecondary),
            onPressed: () => _showVideoOptionsBottomSheet(video),
          ),
        ],
      ),
    );
  }

  Widget _buildFoldersView(List<Video> videos) {
    final colors = context.colors;
    final typography = context.typography;

    // Group videos by folder/directory
    final Map<String, List<Video>> folderMap = {};
    for (final v in videos) {
      final file = File(v.filePath);
      final folderName = file.parent.path.split(Platform.pathSeparator).last;
      final key = folderName.isNotEmpty ? folderName : 'Internal Storage';
      folderMap.putIfAbsent(key, () => []).add(v);
    }

    final folderEntries = folderMap.entries.toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space8),
      itemCount: folderEntries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
      itemBuilder: (ctx, index) {
        final entry = folderEntries[index];
        final folderName = entry.key;
        final folderVideos = entry.value;

        return VioraCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FolderDetailScreen(
                  folderName: folderName,
                  videos: folderVideos,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: AppDimensions.borderRadiusCompact,
                ),
                child: Icon(VioraIcons.folder, color: colors.accent, size: AppDimensions.iconMedium),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(folderName, style: typography.headline),
                    const SizedBox(height: 2),
                    Text(
                      '${folderVideos.length} ${folderVideos.length == 1 ? 'video' : 'videos'}',
                      style: typography.footnote,
                    ),
                  ],
                ),
              ),
              Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: AppDimensions.iconMedium),
            ],
          ),
        );
      },
    );
  }
}

class FolderDetailScreen extends StatelessWidget {
  const FolderDetailScreen({
    super.key,
    required this.folderName,
    required this.videos,
  });

  final String folderName;
  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      appBar: VioraAppBar(
        title: folderName,
        leading: IconButton(
          icon: Icon(VioraIcons.back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.space16),
        itemCount: videos.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
        itemBuilder: (ctx, idx) {
          final video = videos[idx];
          final hasThumb = video.thumbnailPath != null && File(video.thumbnailPath!).existsSync();

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
                Container(
                  width: 80,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: AppDimensions.borderRadiusCompact,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasThumb
                      ? Image.file(File(video.thumbnailPath!), fit: BoxFit.cover)
                      : Center(child: Icon(VioraIcons.video, color: colors.accent)),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title, style: typography.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
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
      ),
    );
  }
}
