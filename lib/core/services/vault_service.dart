import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

abstract interface class VaultService {
  Future<bool> hideVideo(AppDatabase db, Video video, {String? reason});
  Future<bool> unhideVideo(AppDatabase db, Video video);
}

class AndroidVaultService implements VaultService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/vault');

  @override
  Future<bool> hideVideo(AppDatabase db, Video video, {String? reason}) async {
    try {
      final String? vaultPath = await _channel.invokeMethod<String>('hideVideo', {
        'filePath': video.filePath,
        'videoId': video.id,
      });

      if (vaultPath != null && vaultPath.isNotEmpty) {
        await db.transaction(() async {
          // Record in HiddenVideos table
          await db.into(db.hiddenVideos).insert(
                HiddenVideosCompanion.insert(
                  id: video.id,
                  videoId: video.id,
                  hiddenAt: DateTime.now(),
                  reason: Value(reason),
                ),
                mode: InsertMode.insertOrReplace,
              );

          // Update Videos table isHidden and path
          await (db.update(db.videos)..where((tbl) => tbl.id.equals(video.id))).write(
            VideosCompanion(
              filePath: Value(vaultPath),
              isHidden: const Value(true),
            ),
          );
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<bool> unhideVideo(AppDatabase db, Video video) async {
    try {
      final String? restoredPath = await _channel.invokeMethod<String>('unhideVideo', {
        'vaultPath': video.filePath,
        'originalPath': video.filePath,
      });

      if (restoredPath != null && restoredPath.isNotEmpty) {
        await db.transaction(() async {
          await (db.delete(db.hiddenVideos)..where((tbl) => tbl.videoId.equals(video.id))).go();
          await (db.update(db.videos)..where((tbl) => tbl.id.equals(video.id))).write(
            VideosCompanion(
              filePath: Value(restoredPath),
              isHidden: const Value(false),
            ),
          );
        });
        return true;
      }
    } catch (_) {}
    return false;
  }
}

final vaultServiceProvider = Provider<VaultService>((ref) {
  return AndroidVaultService();
});

/// Reactive stream of hidden vault videos
final hiddenVideosProvider = StreamProvider<List<Video>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.videos)
        ..where((tbl) => tbl.isHidden.equals(true))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateModified)]))
      .watch();
});
