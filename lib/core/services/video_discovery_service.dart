import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../utilities/formatters.dart';

@immutable
class DiscoveredVideoMetadata {
  const DiscoveredVideoMetadata({
    required this.id,
    required this.filePath,
    required this.title,
    required this.durationMs,
    required this.sizeBytes,
    required this.dateAdded,
    required this.dateModified,
    required this.mimeType,
    this.width,
    this.height,
    this.bucketId,
    this.bucketDisplayName,
    this.thumbnailPath,
  });

  final String id;
  final String filePath;
  final String title;
  final int durationMs;
  final int sizeBytes;
  final DateTime dateAdded;
  final DateTime dateModified;
  final String mimeType;
  final int? width;
  final int? height;
  final String? bucketId;
  final String? bucketDisplayName;
  final String? thumbnailPath;

  factory DiscoveredVideoMetadata.fromMap(Map<String, dynamic> map) {
    return DiscoveredVideoMetadata(
      id: map['id']?.toString() ?? '',
      filePath: map['filePath'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled',
      durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      dateAdded: DateTime.fromMillisecondsSinceEpoch(
        (map['dateAddedMs'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      dateModified: DateTime.fromMillisecondsSinceEpoch(
        (map['dateModifiedMs'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      mimeType: map['mimeType'] as String? ?? 'video/*',
      width: (map['width'] as num?)?.toInt(),
      height: (map['height'] as num?)?.toInt(),
      bucketId: map['bucketId']?.toString(),
      bucketDisplayName: map['bucketDisplayName'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
    );
  }
}

abstract interface class VideoDiscoveryService {
  Future<List<DiscoveredVideoMetadata>> scanVideos({int minDurationMs = 1000});
  Future<int> syncWithDatabase(AppDatabase db, {int minDurationMs = 1000});
  Future<String?> generateThumbnail({required String filePath, required String videoId});
}

class AndroidMediaStoreService implements VideoDiscoveryService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/mediastore');

  @override
  Future<String?> generateThumbnail({required String filePath, required String videoId}) async {
    try {
      final String? path = await _channel.invokeMethod<String>(
        'generateThumbnail',
        {'filePath': filePath, 'videoId': videoId},
      );
      return path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DiscoveredVideoMetadata>> scanVideos({int minDurationMs = 1000}) async {
    try {
      final List<dynamic>? rawList = await _channel.invokeMethod<List<dynamic>>(
        'scanVideos',
        {'minDurationMs': minDurationMs},
      );

      if (rawList == null) return const [];
      return rawList
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => DiscoveredVideoMetadata.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<int> syncWithDatabase(AppDatabase db, {int minDurationMs = 1000}) async {
    final discovered = await scanVideos(minDurationMs: minDurationMs);
    if (discovered.isEmpty) return 0;

    int syncedCount = 0;
    await db.batch((batch) {
      for (final item in discovered) {
        batch.insert(
          db.videos,
          VideosCompanion.insert(
            id: item.id,
            filePath: item.filePath,
            title: item.title,
            durationMs: Value(item.durationMs),
            sizeBytes: Value(item.sizeBytes),
            dateAdded: item.dateAdded,
            dateModified: item.dateModified,
            mimeType: Value(item.mimeType),
            width: Value(item.width),
            height: Value(item.height),
            resolution: Value(Formatters.formatResolution(item.width, item.height)),
            thumbnailPath: Value(item.thumbnailPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
        syncedCount++;
      }
    });

    return syncedCount;
  }
}

final videoDiscoveryServiceProvider = Provider<VideoDiscoveryService>((ref) {
  return AndroidMediaStoreService();
});

/// Reactive stream of all unhidden videos in database.
final libraryVideosProvider = StreamProvider<List<Video>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.videos)
        ..where((tbl) => tbl.isHidden.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateModified)]))
      .watch();
});

/// Reactive stream of favorite videos.
final favoriteVideosProvider = StreamProvider<List<Video>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.videos)
        ..where((tbl) => tbl.isFavorite.equals(true) & tbl.isHidden.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateModified)]))
      .watch();
});
