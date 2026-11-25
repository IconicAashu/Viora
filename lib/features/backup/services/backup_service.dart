import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/database/database.dart';

class BackupResult {
  const BackupResult({
    required this.success,
    this.filePath,
    this.message,
    this.restoredCollections = 0,
    this.restoredPreferences = 0,
  });

  final bool success;
  final String? filePath;
  final String? message;
  final int restoredCollections;
  final int restoredPreferences;
}

class BackupService {
  Future<BackupResult> exportBackup(AppDatabase db) async {
    try {
      final collections = await db.select(db.collections).get();
      final collectionVideos = await db.select(db.collectionVideos).get();
      final preferences = await db.select(db.userPreferences).get();
      final favorites = await (db.select(db.videos)..where((tbl) => tbl.isFavorite.equals(true))).get();

      final backupData = {
        'version': 1,
        'appName': 'VIORA',
        'exportedAt': DateTime.now().toIso8601String(),
        'notice': 'VIORA backup files contain only metadata, playlists, and settings. Original video files are never copied or exported.',
        'collections': collections.map((c) => {
          'id': c.id,
          'name': c.name,
          'description': c.description,
          'createdAt': c.createdAt.toIso8601String(),
          'updatedAt': c.updatedAt.toIso8601String(),
          'coverVideoId': c.coverVideoId,
        }).toList(),
        'collectionVideos': collectionVideos.map((cv) => {
          'id': cv.id,
          'collectionId': cv.collectionId,
          'videoId': cv.videoId,
          'orderIndex': cv.orderIndex,
          'addedAt': cv.addedAt.toIso8601String(),
        }).toList(),
        'favoriteVideoPaths': favorites.map((f) => f.filePath).toList(),
        'preferences': preferences.map((p) => {
          'key': p.key,
          'value': p.value,
          'updatedAt': p.updatedAt.toIso8601String(),
        }).toList(),
      };

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'viora_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(backupData));

      return BackupResult(
        success: true,
        filePath: file.path,
        message: 'Backup created successfully: $fileName',
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Failed to create backup: $e',
      );
    }
  }

  Future<BackupResult> restoreBackup(AppDatabase db, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const BackupResult(success: false, message: 'Backup file does not exist');
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (data['appName'] != 'VIORA') {
        return const BackupResult(success: false, message: 'Invalid backup format (Not a VIORA backup)');
      }

      int colsRestored = 0;
      int prefsRestored = 0;

      await db.transaction(() async {
        // Restore collections
        final collectionsList = data['collections'] as List<dynamic>? ?? [];
        for (final item in collectionsList) {
          final map = item as Map<String, dynamic>;
          await db.into(db.collections).insertOnConflictUpdate(
                CollectionsCompanion.insert(
                  id: map['id'] as String,
                  name: map['name'] as String,
                  description: Value(map['description'] as String?),
                  createdAt: DateTime.parse(map['createdAt'] as String),
                  updatedAt: DateTime.parse(map['updatedAt'] as String),
                  coverVideoId: Value(map['coverVideoId'] as String?),
                ),
              );
          colsRestored++;
        }

        // Restore collection videos
        final cvList = data['collectionVideos'] as List<dynamic>? ?? [];
        for (final item in cvList) {
          final map = item as Map<String, dynamic>;
          await db.into(db.collectionVideos).insertOnConflictUpdate(
                CollectionVideosCompanion.insert(
                  id: map['id'] as String,
                  collectionId: map['collectionId'] as String,
                  videoId: map['videoId'] as String,
                  orderIndex: Value(map['orderIndex'] as int? ?? 0),
                  addedAt: DateTime.parse(map['addedAt'] as String),
                ),
              );
        }

        // Restore favorite flags
        final favoritePaths = (data['favoriteVideoPaths'] as List<dynamic>? ?? []).cast<String>();
        for (final path in favoritePaths) {
          await (db.update(db.videos)..where((tbl) => tbl.filePath.equals(path))).write(
            const VideosCompanion(isFavorite: Value(true)),
          );
        }

        // Restore preferences
        final prefsList = data['preferences'] as List<dynamic>? ?? [];
        for (final item in prefsList) {
          final map = item as Map<String, dynamic>;
          await db.into(db.userPreferences).insertOnConflictUpdate(
                UserPreferencesCompanion.insert(
                  key: map['key'] as String,
                  value: map['value'] as String,
                  updatedAt: DateTime.parse(map['updatedAt'] as String),
                ),
              );
          prefsRestored++;
        }
      });

      return BackupResult(
        success: true,
        restoredCollections: colsRestored,
        restoredPreferences: prefsRestored,
        message: 'Successfully restored $colsRestored collections and preferences.',
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Failed to restore backup: $e',
      );
    }
  }

  Future<List<File>> listBackups() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final entities = dir.listSync();
      return entities
          .whereType<File>()
          .where((f) => f.path.contains('viora_backup_') && f.path.endsWith('.json'))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});
