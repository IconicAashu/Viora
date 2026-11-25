import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/services/video_discovery_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/formatters.dart';
import '../../../shared/widgets/viora_app_bar.dart';
import '../../../shared/widgets/viora_card.dart';
import '../../../shared/widgets/viora_empty_state.dart';
import '../../../shared/widgets/viora_video_thumbnail.dart';
import '../../player/presentation/video_player_screen.dart';

/// Reactive provider for all user-created collections
final collectionsStreamProvider = StreamProvider<List<Collection>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.collections)
        ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.updatedAt)]))
      .watch();
});

/// Reactive provider for recently played videos ordered by latest playback timestamp.
/// Queries PlaybackHistory joined with Videos, deduplicates by videoId, and excludes hidden videos.
final recentlyPlayedVideosProvider = StreamProvider<List<Video>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.playbackHistory).join([
    drift.innerJoin(db.videos, db.videos.id.equalsExp(db.playbackHistory.videoId)),
  ])
    ..where(db.videos.isHidden.equals(false))
    ..orderBy([drift.OrderingTerm.desc(db.playbackHistory.playedAt)]);

  return query.watch().map((rows) {
    final seenIds = <String>{};
    final result = <Video>[];
    for (final row in rows) {
      final video = row.readTable(db.videos);
      if (seenIds.add(video.id)) {
        result.add(video);
      }
    }
    return result;
  });
});

/// Reactive provider for in-progress videos strictly eligible for Continue Watching
final continueWatchingVideosProvider = StreamProvider<List<Video>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.videos)
        ..where((tbl) =>
            tbl.lastPlayedPositionMs.isBiggerThanValue(3000) &
            tbl.isHidden.equals(false))
        ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.dateModified)]))
      .watch()
      .map((videos) => videos.where((v) => (v.durationMs - v.lastPlayedPositionMs) > 5000).toList());
});

/// Reactive provider for recently added videos (last 30)
final recentlyAddedVideosProvider = StreamProvider<List<Video>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.videos)
        ..where((tbl) => tbl.isHidden.equals(false))
        ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.dateAdded)])
        ..limit(30))
      .watch();
});

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
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
              hintText: 'e.g. Travel, Lectures, Favorites',
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
                  await db.into(db.collections).insert(
                        CollectionsCompanion.insert(
                          id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
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

  void _showRenameCollectionDialog(BuildContext context, WidgetRef ref, Collection collection) {
    final textController = TextEditingController(text: collection.name);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Rename Collection', style: context.typography.title3),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: context.typography.body,
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
                  await (db.update(db.collections)..where((tbl) => tbl.id.equals(collection.id))).write(
                    CollectionsCompanion(
                      name: drift.Value(name),
                      updatedAt: drift.Value(DateTime.now()),
                    ),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                }
              },
              child: Text('Save', style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCollection(BuildContext context, WidgetRef ref, Collection collection) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Delete "${collection.name}"?', style: context.typography.title3),
          content: Text(
            'This will delete the collection playlist. Video files on your device will NOT be deleted.',
            style: context.typography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final db = ref.read(appDatabaseProvider);
                await (db.delete(db.collections)..where((tbl) => tbl.id.equals(collection.id))).go();
                await (db.delete(db.collectionVideos)..where((tbl) => tbl.collectionId.equals(collection.id))).go();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              child: Text('Delete', style: TextStyle(color: context.colors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    final favoritesAsync = ref.watch(favoriteVideosProvider);
    final recentlyPlayedAsync = ref.watch(recentlyPlayedVideosProvider);
    final recentlyAddedAsync = ref.watch(recentlyAddedVideosProvider);
    final collectionsAsync = ref.watch(collectionsStreamProvider);

    return Scaffold(
      appBar: VioraAppBar(
        title: 'Collections',
        isLargeTitle: true,
        actions: [
          IconButton(
            icon: Icon(VioraIcons.plusCircle, color: colors.accent, size: 22),
            onPressed: () => _showCreateCollectionDialog(context, ref),
            tooltip: 'New Collection',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
        children: [
          // Smart Collections
          Text('Smart Collections', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),

          Row(
            children: [
              // Favorites Tile
              Expanded(
                child: VioraCard(
                  onTap: () {
                    final videos = favoritesAsync.value ?? [];
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailScreen(
                          title: 'Favorites',
                          icon: VioraIcons.favorites,
                          videos: videos,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.danger.withValues(alpha: 0.12),
                          borderRadius: AppDimensions.borderRadiusCompact,
                        ),
                        child: Icon(VioraIcons.favorites, color: colors.danger, size: 24),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      Text('Favorites', style: typography.headline),
                      const SizedBox(height: 2),
                      Text(
                        '${favoritesAsync.value?.length ?? 0} videos',
                        style: typography.footnote,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // Recently Played Tile
              Expanded(
                child: VioraCard(
                  onTap: () {
                    final videos = recentlyPlayedAsync.value ?? [];
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailScreen(
                          title: 'Recently Played',
                          icon: VioraIcons.recent,
                          videos: videos,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.12),
                          borderRadius: AppDimensions.borderRadiusCompact,
                        ),
                        child: Icon(VioraIcons.recent, color: colors.warning, size: 24),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      Text('Recent', style: typography.headline),
                      const SizedBox(height: 2),
                      Text(
                        '${recentlyPlayedAsync.value?.length ?? 0} videos',
                        style: typography.footnote,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Recently Added Tile
          VioraCard(
            onTap: () {
              final videos = recentlyAddedAsync.value ?? [];
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CollectionDetailScreen(
                    title: 'Recently Added',
                    icon: VioraIcons.sparkles,
                    videos: videos,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.12),
                    borderRadius: AppDimensions.borderRadiusCompact,
                  ),
                  child: Icon(VioraIcons.sparkles, color: colors.accent, size: 22),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recently Added', style: typography.headline),
                      const SizedBox(height: 2),
                      Text('${recentlyAddedAsync.value?.length ?? 0} videos indexed recently', style: typography.footnote),
                    ],
                  ),
                ),
                Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // User Collections Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Playlists', style: typography.title3),
              TextButton.icon(
                onPressed: () => _showCreateCollectionDialog(context, ref),
                icon: Icon(VioraIcons.plus, size: 16, color: colors.accent),
                label: Text('New', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),

          // Collections List
          collectionsAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
            error: (e, _) => Text('Error: $e', style: TextStyle(color: colors.danger)),
            data: (collections) {
              if (collections.isEmpty) {
                return VioraCard(
                  onTap: () => _showCreateCollectionDialog(context, ref),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space16),
                      child: Column(
                        children: [
                          Icon(VioraIcons.folder, color: colors.textTertiary, size: 36),
                          const SizedBox(height: AppDimensions.space8),
                          Text('Create your first playlist', style: typography.headline),
                          const SizedBox(height: 4),
                          Text('Group videos by topic, trip, or project', style: typography.footnote),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: collections.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
                itemBuilder: (ctx, idx) {
                  final col = collections[idx];
                  return _buildCollectionRow(context, ref, col);
                },
              );
            },
          ),

          const SizedBox(height: AppDimensions.bottomNavBarHeight + AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildCollectionRow(BuildContext context, WidgetRef ref, Collection collection) {
    final colors = context.colors;
    final typography = context.typography;
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<Video>>(
      stream: (db.select(db.collectionVideos).join([
        drift.innerJoin(db.videos, db.videos.id.equalsExp(db.collectionVideos.videoId)),
      ])
            ..where(db.collectionVideos.collectionId.equals(collection.id))
            ..orderBy([drift.OrderingTerm.asc(db.collectionVideos.orderIndex)]))
          .watch()
          .map((rows) => rows.map((r) => r.readTable(db.videos)).toList()),
      builder: (context, snapshot) {
        final videos = snapshot.data ?? [];

        return VioraCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CollectionDetailScreen(
                  title: collection.name,
                  collection: collection,
                  videos: videos,
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
                  color: colors.accent.withValues(alpha: 0.12),
                  borderRadius: AppDimensions.borderRadiusCompact,
                ),
                child: Icon(VioraIcons.playlist, color: colors.accent, size: AppDimensions.iconMedium),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.name, style: typography.headline),
                    const SizedBox(height: 2),
                    Text(
                      '${videos.length} ${videos.length == 1 ? 'video' : 'videos'}',
                      style: typography.footnote,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(VioraIcons.more, size: 18, color: colors.textSecondary),
                color: colors.surface,
                onSelected: (val) {
                  if (val == 'rename') {
                    _showRenameCollectionDialog(context, ref, collection);
                  } else if (val == 'delete') {
                    _confirmDeleteCollection(context, ref, collection);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(VioraIcons.edit, size: 16, color: colors.textPrimary),
                        const SizedBox(width: 8),
                        Text('Rename', style: typography.body),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(VioraIcons.delete, size: 16, color: colors.danger),
                        const SizedBox(width: 8),
                        Text('Delete', style: typography.body.copyWith(color: colors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({
    super.key,
    required this.title,
    this.icon,
    this.collection,
    required this.videos,
  });

  final String title;
  final IconData? icon;
  final Collection? collection;
  final List<Video> videos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final db = ref.read(appDatabaseProvider);

    return Scaffold(
      appBar: VioraAppBar(
        title: title,
        leading: IconButton(
          icon: Icon(VioraIcons.back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (videos.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                      video: videos.first,
                      playlist: videos,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              icon: const Icon(VioraIcons.play, size: 16, color: Colors.white),
              label: const Text('Play All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: colors.accent,
                shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCompact),
              ),
            ),
        ],
      ),
      body: videos.isEmpty
          ? Center(
              child: VioraEmptyState(
                icon: icon ?? VioraIcons.folder,
                title: 'No Videos Here',
                description: 'Add videos to this collection from your library.',
              ),
            )
          : ListView.separated(
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
                            Text(video.title, style: typography.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                              '${Formatters.formatDuration(video.durationMs)} • ${Formatters.formatFileSize(video.sizeBytes)}',
                              style: typography.footnote,
                            ),
                          ],
                        ),
                      ),
                      if (collection != null)
                        IconButton(
                          icon: Icon(VioraIcons.close, size: 18, color: colors.textSecondary),
                          tooltip: 'Remove from playlist',
                          onPressed: () async {
                            await (db.delete(db.collectionVideos)
                                  ..where((tbl) =>
                                      tbl.collectionId.equals(collection!.id) & tbl.videoId.equals(video.id)))
                                .go();
                            if (context.mounted) {
                              Navigator.pop(context); // reload or rebuild
                            }
                          },
                        )
                      else
                        Icon(VioraIcons.play, color: colors.accent, size: 18),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
