import 'package:drift/drift.dart';

/// Videos table: stores metadata and path references, never original video binary data.
class Videos extends Table {
  TextColumn get id => text()();
  TextColumn get filePath => text().unique()();
  TextColumn get title => text()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get dateAdded => dateTime()();
  DateTimeColumn get dateModified => dateTime()();
  TextColumn get mimeType => text().withDefault(const Constant('video/*'))();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get resolution => text().nullable()();
  IntColumn get lastPlayedPositionMs => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get thumbnailPath => text().nullable()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Collections table: user-defined playlists and smart collections.
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get coverVideoId => text().nullable()();
  BoolColumn get isSmartCollection => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// CollectionVideos table: mapping table for many-to-many relationship with ordering.
class CollectionVideos extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text()();
  TextColumn get videoId => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// PlaybackHistory table: stores past video playback sessions for resume and history.
class PlaybackHistory extends Table {
  TextColumn get id => text()();
  TextColumn get videoId => text()();
  DateTimeColumn get playedAt => dateTime()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// UserPreferences table: key-value storage for local settings.
class UserPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// HiddenVideos table: videos hidden from general library (private vault reference).
class HiddenVideos extends Table {
  TextColumn get id => text()();
  TextColumn get videoId => text().unique()();
  DateTimeColumn get hiddenAt => dateTime()();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
