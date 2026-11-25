import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Videos,
  Collections,
  CollectionVideos,
  PlaybackHistory,
  UserPreferences,
  HiddenVideos,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'viora_local');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Extensible migration hooks for future versions
        // e.g., if (from < 2) { ... }
      },
      beforeOpen: (details) async {
        // Enforce SQLite foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

/// Singleton Drift database provider for Riverpod.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
