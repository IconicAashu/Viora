// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VideosTable extends Videos with TableInfo<$VideosTable, Video> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateModifiedMeta = const VerificationMeta(
    'dateModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateModified = GeneratedColumn<DateTime>(
    'date_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('video/*'),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPlayedPositionMsMeta =
      const VerificationMeta('lastPlayedPositionMs');
  @override
  late final GeneratedColumn<int> lastPlayedPositionMs = GeneratedColumn<int>(
    'last_played_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    title,
    durationMs,
    sizeBytes,
    dateAdded,
    dateModified,
    mimeType,
    width,
    height,
    resolution,
    lastPlayedPositionMs,
    isFavorite,
    thumbnailPath,
    isHidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Video> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('date_modified')) {
      context.handle(
        _dateModifiedMeta,
        dateModified.isAcceptableOrUnknown(
          data['date_modified']!,
          _dateModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateModifiedMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    if (data.containsKey('last_played_position_ms')) {
      context.handle(
        _lastPlayedPositionMsMeta,
        lastPlayedPositionMs.isAcceptableOrUnknown(
          data['last_played_position_ms']!,
          _lastPlayedPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Video map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Video(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      dateModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_modified'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
      lastPlayedPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played_position_ms'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $VideosTable createAlias(String alias) {
    return $VideosTable(attachedDatabase, alias);
  }
}

class Video extends DataClass implements Insertable<Video> {
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
  final String? resolution;
  final int lastPlayedPositionMs;
  final bool isFavorite;
  final String? thumbnailPath;
  final bool isHidden;
  const Video({
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
    this.resolution,
    required this.lastPlayedPositionMs,
    required this.isFavorite,
    this.thumbnailPath,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_path'] = Variable<String>(filePath);
    map['title'] = Variable<String>(title);
    map['duration_ms'] = Variable<int>(durationMs);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['date_modified'] = Variable<DateTime>(dateModified);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    map['last_played_position_ms'] = Variable<int>(lastPlayedPositionMs);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['is_hidden'] = Variable<bool>(isHidden);
    return map;
  }

  VideosCompanion toCompanion(bool nullToAbsent) {
    return VideosCompanion(
      id: Value(id),
      filePath: Value(filePath),
      title: Value(title),
      durationMs: Value(durationMs),
      sizeBytes: Value(sizeBytes),
      dateAdded: Value(dateAdded),
      dateModified: Value(dateModified),
      mimeType: Value(mimeType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
      lastPlayedPositionMs: Value(lastPlayedPositionMs),
      isFavorite: Value(isFavorite),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      isHidden: Value(isHidden),
    );
  }

  factory Video.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Video(
      id: serializer.fromJson<String>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      title: serializer.fromJson<String>(json['title']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      dateModified: serializer.fromJson<DateTime>(json['dateModified']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      lastPlayedPositionMs: serializer.fromJson<int>(
        json['lastPlayedPositionMs'],
      ),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filePath': serializer.toJson<String>(filePath),
      'title': serializer.toJson<String>(title),
      'durationMs': serializer.toJson<int>(durationMs),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'dateModified': serializer.toJson<DateTime>(dateModified),
      'mimeType': serializer.toJson<String>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'resolution': serializer.toJson<String?>(resolution),
      'lastPlayedPositionMs': serializer.toJson<int>(lastPlayedPositionMs),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  Video copyWith({
    String? id,
    String? filePath,
    String? title,
    int? durationMs,
    int? sizeBytes,
    DateTime? dateAdded,
    DateTime? dateModified,
    String? mimeType,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
    int? lastPlayedPositionMs,
    bool? isFavorite,
    Value<String?> thumbnailPath = const Value.absent(),
    bool? isHidden,
  }) => Video(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    title: title ?? this.title,
    durationMs: durationMs ?? this.durationMs,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    dateAdded: dateAdded ?? this.dateAdded,
    dateModified: dateModified ?? this.dateModified,
    mimeType: mimeType ?? this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    resolution: resolution.present ? resolution.value : this.resolution,
    lastPlayedPositionMs: lastPlayedPositionMs ?? this.lastPlayedPositionMs,
    isFavorite: isFavorite ?? this.isFavorite,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    isHidden: isHidden ?? this.isHidden,
  );
  Video copyWithCompanion(VideosCompanion data) {
    return Video(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      title: data.title.present ? data.title.value : this.title,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      dateModified: data.dateModified.present
          ? data.dateModified.value
          : this.dateModified,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      lastPlayedPositionMs: data.lastPlayedPositionMs.present
          ? data.lastPlayedPositionMs.value
          : this.lastPlayedPositionMs,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Video(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('resolution: $resolution, ')
          ..write('lastPlayedPositionMs: $lastPlayedPositionMs, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    title,
    durationMs,
    sizeBytes,
    dateAdded,
    dateModified,
    mimeType,
    width,
    height,
    resolution,
    lastPlayedPositionMs,
    isFavorite,
    thumbnailPath,
    isHidden,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Video &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.title == this.title &&
          other.durationMs == this.durationMs &&
          other.sizeBytes == this.sizeBytes &&
          other.dateAdded == this.dateAdded &&
          other.dateModified == this.dateModified &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.resolution == this.resolution &&
          other.lastPlayedPositionMs == this.lastPlayedPositionMs &&
          other.isFavorite == this.isFavorite &&
          other.thumbnailPath == this.thumbnailPath &&
          other.isHidden == this.isHidden);
}

class VideosCompanion extends UpdateCompanion<Video> {
  final Value<String> id;
  final Value<String> filePath;
  final Value<String> title;
  final Value<int> durationMs;
  final Value<int> sizeBytes;
  final Value<DateTime> dateAdded;
  final Value<DateTime> dateModified;
  final Value<String> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String?> resolution;
  final Value<int> lastPlayedPositionMs;
  final Value<bool> isFavorite;
  final Value<String?> thumbnailPath;
  final Value<bool> isHidden;
  final Value<int> rowid;
  const VideosCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.resolution = const Value.absent(),
    this.lastPlayedPositionMs = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideosCompanion.insert({
    required String id,
    required String filePath,
    required String title,
    this.durationMs = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    required DateTime dateAdded,
    required DateTime dateModified,
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.resolution = const Value.absent(),
    this.lastPlayedPositionMs = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       filePath = Value(filePath),
       title = Value(title),
       dateAdded = Value(dateAdded),
       dateModified = Value(dateModified);
  static Insertable<Video> custom({
    Expression<String>? id,
    Expression<String>? filePath,
    Expression<String>? title,
    Expression<int>? durationMs,
    Expression<int>? sizeBytes,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? dateModified,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? resolution,
    Expression<int>? lastPlayedPositionMs,
    Expression<bool>? isFavorite,
    Expression<String>? thumbnailPath,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (dateAdded != null) 'date_added': dateAdded,
      if (dateModified != null) 'date_modified': dateModified,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (resolution != null) 'resolution': resolution,
      if (lastPlayedPositionMs != null)
        'last_played_position_ms': lastPlayedPositionMs,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (isHidden != null) 'is_hidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideosCompanion copyWith({
    Value<String>? id,
    Value<String>? filePath,
    Value<String>? title,
    Value<int>? durationMs,
    Value<int>? sizeBytes,
    Value<DateTime>? dateAdded,
    Value<DateTime>? dateModified,
    Value<String>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<String?>? resolution,
    Value<int>? lastPlayedPositionMs,
    Value<bool>? isFavorite,
    Value<String?>? thumbnailPath,
    Value<bool>? isHidden,
    Value<int>? rowid,
  }) {
    return VideosCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      resolution: resolution ?? this.resolution,
      lastPlayedPositionMs: lastPlayedPositionMs ?? this.lastPlayedPositionMs,
      isFavorite: isFavorite ?? this.isFavorite,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (dateModified.present) {
      map['date_modified'] = Variable<DateTime>(dateModified.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (lastPlayedPositionMs.present) {
      map['last_played_position_ms'] = Variable<int>(
        lastPlayedPositionMs.value,
      );
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideosCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('resolution: $resolution, ')
          ..write('lastPlayedPositionMs: $lastPlayedPositionMs, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverVideoIdMeta = const VerificationMeta(
    'coverVideoId',
  );
  @override
  late final GeneratedColumn<String> coverVideoId = GeneratedColumn<String>(
    'cover_video_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSmartCollectionMeta = const VerificationMeta(
    'isSmartCollection',
  );
  @override
  late final GeneratedColumn<bool> isSmartCollection = GeneratedColumn<bool>(
    'is_smart_collection',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_smart_collection" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
    coverVideoId,
    isSmartCollection,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cover_video_id')) {
      context.handle(
        _coverVideoIdMeta,
        coverVideoId.isAcceptableOrUnknown(
          data['cover_video_id']!,
          _coverVideoIdMeta,
        ),
      );
    }
    if (data.containsKey('is_smart_collection')) {
      context.handle(
        _isSmartCollectionMeta,
        isSmartCollection.isAcceptableOrUnknown(
          data['is_smart_collection']!,
          _isSmartCollectionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      coverVideoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_video_id'],
      ),
      isSmartCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_smart_collection'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverVideoId;
  final bool isSmartCollection;
  const Collection({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.coverVideoId,
    required this.isSmartCollection,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || coverVideoId != null) {
      map['cover_video_id'] = Variable<String>(coverVideoId);
    }
    map['is_smart_collection'] = Variable<bool>(isSmartCollection);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      coverVideoId: coverVideoId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverVideoId),
      isSmartCollection: Value(isSmartCollection),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      coverVideoId: serializer.fromJson<String?>(json['coverVideoId']),
      isSmartCollection: serializer.fromJson<bool>(json['isSmartCollection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'coverVideoId': serializer.toJson<String?>(coverVideoId),
      'isSmartCollection': serializer.toJson<bool>(isSmartCollection),
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> coverVideoId = const Value.absent(),
    bool? isSmartCollection,
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    coverVideoId: coverVideoId.present ? coverVideoId.value : this.coverVideoId,
    isSmartCollection: isSmartCollection ?? this.isSmartCollection,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      coverVideoId: data.coverVideoId.present
          ? data.coverVideoId.value
          : this.coverVideoId,
      isSmartCollection: data.isSmartCollection.present
          ? data.isSmartCollection.value
          : this.isSmartCollection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('coverVideoId: $coverVideoId, ')
          ..write('isSmartCollection: $isSmartCollection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    updatedAt,
    coverVideoId,
    isSmartCollection,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.coverVideoId == this.coverVideoId &&
          other.isSmartCollection == this.isSmartCollection);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> coverVideoId;
  final Value<bool> isSmartCollection;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.coverVideoId = const Value.absent(),
    this.isSmartCollection = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.coverVideoId = const Value.absent(),
    this.isSmartCollection = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? coverVideoId,
    Expression<bool>? isSmartCollection,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (coverVideoId != null) 'cover_video_id': coverVideoId,
      if (isSmartCollection != null) 'is_smart_collection': isSmartCollection,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? coverVideoId,
    Value<bool>? isSmartCollection,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverVideoId: coverVideoId ?? this.coverVideoId,
      isSmartCollection: isSmartCollection ?? this.isSmartCollection,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (coverVideoId.present) {
      map['cover_video_id'] = Variable<String>(coverVideoId.value);
    }
    if (isSmartCollection.present) {
      map['is_smart_collection'] = Variable<bool>(isSmartCollection.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('coverVideoId: $coverVideoId, ')
          ..write('isSmartCollection: $isSmartCollection, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionVideosTable extends CollectionVideos
    with TableInfo<$CollectionVideosTable, CollectionVideo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionVideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    videoId,
    orderIndex,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionVideo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionVideo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionVideo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CollectionVideosTable createAlias(String alias) {
    return $CollectionVideosTable(attachedDatabase, alias);
  }
}

class CollectionVideo extends DataClass implements Insertable<CollectionVideo> {
  final String id;
  final String collectionId;
  final String videoId;
  final int orderIndex;
  final DateTime addedAt;
  const CollectionVideo({
    required this.id,
    required this.collectionId,
    required this.videoId,
    required this.orderIndex,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['video_id'] = Variable<String>(videoId);
    map['order_index'] = Variable<int>(orderIndex);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CollectionVideosCompanion toCompanion(bool nullToAbsent) {
    return CollectionVideosCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      videoId: Value(videoId),
      orderIndex: Value(orderIndex),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionVideo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionVideo(
      id: serializer.fromJson<String>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      videoId: serializer.fromJson<String>(json['videoId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'videoId': serializer.toJson<String>(videoId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CollectionVideo copyWith({
    String? id,
    String? collectionId,
    String? videoId,
    int? orderIndex,
    DateTime? addedAt,
  }) => CollectionVideo(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    videoId: videoId ?? this.videoId,
    orderIndex: orderIndex ?? this.orderIndex,
    addedAt: addedAt ?? this.addedAt,
  );
  CollectionVideo copyWithCompanion(CollectionVideosCompanion data) {
    return CollectionVideo(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionVideo(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('videoId: $videoId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, collectionId, videoId, orderIndex, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionVideo &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.videoId == this.videoId &&
          other.orderIndex == this.orderIndex &&
          other.addedAt == this.addedAt);
}

class CollectionVideosCompanion extends UpdateCompanion<CollectionVideo> {
  final Value<String> id;
  final Value<String> collectionId;
  final Value<String> videoId;
  final Value<int> orderIndex;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CollectionVideosCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.videoId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionVideosCompanion.insert({
    required String id,
    required String collectionId,
    required String videoId,
    this.orderIndex = const Value.absent(),
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectionId = Value(collectionId),
       videoId = Value(videoId),
       addedAt = Value(addedAt);
  static Insertable<CollectionVideo> custom({
    Expression<String>? id,
    Expression<String>? collectionId,
    Expression<String>? videoId,
    Expression<int>? orderIndex,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (videoId != null) 'video_id': videoId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionVideosCompanion copyWith({
    Value<String>? id,
    Value<String>? collectionId,
    Value<String>? videoId,
    Value<int>? orderIndex,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CollectionVideosCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      videoId: videoId ?? this.videoId,
      orderIndex: orderIndex ?? this.orderIndex,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionVideosCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('videoId: $videoId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackHistoryTable extends PlaybackHistory
    with TableInfo<$PlaybackHistoryTable, PlaybackHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    videoId,
    playedAt,
    positionMs,
    durationMs,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $PlaybackHistoryTable createAlias(String alias) {
    return $PlaybackHistoryTable(attachedDatabase, alias);
  }
}

class PlaybackHistoryData extends DataClass
    implements Insertable<PlaybackHistoryData> {
  final String id;
  final String videoId;
  final DateTime playedAt;
  final int positionMs;
  final int durationMs;
  final bool completed;
  const PlaybackHistoryData({
    required this.id,
    required this.videoId,
    required this.playedAt,
    required this.positionMs,
    required this.durationMs,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['video_id'] = Variable<String>(videoId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  PlaybackHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlaybackHistoryCompanion(
      id: Value(id),
      videoId: Value(videoId),
      playedAt: Value(playedAt),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      completed: Value(completed),
    );
  }

  factory PlaybackHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackHistoryData(
      id: serializer.fromJson<String>(json['id']),
      videoId: serializer.fromJson<String>(json['videoId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'videoId': serializer.toJson<String>(videoId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  PlaybackHistoryData copyWith({
    String? id,
    String? videoId,
    DateTime? playedAt,
    int? positionMs,
    int? durationMs,
    bool? completed,
  }) => PlaybackHistoryData(
    id: id ?? this.id,
    videoId: videoId ?? this.videoId,
    playedAt: playedAt ?? this.playedAt,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    completed: completed ?? this.completed,
  );
  PlaybackHistoryData copyWithCompanion(PlaybackHistoryCompanion data) {
    return PlaybackHistoryData(
      id: data.id.present ? data.id.value : this.id,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoryData(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('playedAt: $playedAt, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, videoId, playedAt, positionMs, durationMs, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackHistoryData &&
          other.id == this.id &&
          other.videoId == this.videoId &&
          other.playedAt == this.playedAt &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.completed == this.completed);
}

class PlaybackHistoryCompanion extends UpdateCompanion<PlaybackHistoryData> {
  final Value<String> id;
  final Value<String> videoId;
  final Value<DateTime> playedAt;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<bool> completed;
  final Value<int> rowid;
  const PlaybackHistoryCompanion({
    this.id = const Value.absent(),
    this.videoId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackHistoryCompanion.insert({
    required String id,
    required String videoId,
    required DateTime playedAt,
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       videoId = Value(videoId),
       playedAt = Value(playedAt);
  static Insertable<PlaybackHistoryData> custom({
    Expression<String>? id,
    Expression<String>? videoId,
    Expression<DateTime>? playedAt,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<bool>? completed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoId != null) 'video_id': videoId,
      if (playedAt != null) 'played_at': playedAt,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (completed != null) 'completed': completed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? videoId,
    Value<DateTime>? playedAt,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<bool>? completed,
    Value<int>? rowid,
  }) {
    return PlaybackHistoryCompanion(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      playedAt: playedAt ?? this.playedAt,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      completed: completed ?? this.completed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoryCompanion(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('playedAt: $playedAt, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('completed: $completed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const UserPreference({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPreference copyWith({String? key, String? value, DateTime? updatedAt}) =>
      UserPreference(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<UserPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HiddenVideosTable extends HiddenVideos
    with TableInfo<$HiddenVideosTable, HiddenVideo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HiddenVideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _hiddenAtMeta = const VerificationMeta(
    'hiddenAt',
  );
  @override
  late final GeneratedColumn<DateTime> hiddenAt = GeneratedColumn<DateTime>(
    'hidden_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, videoId, hiddenAt, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden_videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<HiddenVideo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('hidden_at')) {
      context.handle(
        _hiddenAtMeta,
        hiddenAt.isAcceptableOrUnknown(data['hidden_at']!, _hiddenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_hiddenAtMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HiddenVideo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HiddenVideo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      hiddenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hidden_at'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $HiddenVideosTable createAlias(String alias) {
    return $HiddenVideosTable(attachedDatabase, alias);
  }
}

class HiddenVideo extends DataClass implements Insertable<HiddenVideo> {
  final String id;
  final String videoId;
  final DateTime hiddenAt;
  final String? reason;
  const HiddenVideo({
    required this.id,
    required this.videoId,
    required this.hiddenAt,
    this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['video_id'] = Variable<String>(videoId);
    map['hidden_at'] = Variable<DateTime>(hiddenAt);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  HiddenVideosCompanion toCompanion(bool nullToAbsent) {
    return HiddenVideosCompanion(
      id: Value(id),
      videoId: Value(videoId),
      hiddenAt: Value(hiddenAt),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory HiddenVideo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HiddenVideo(
      id: serializer.fromJson<String>(json['id']),
      videoId: serializer.fromJson<String>(json['videoId']),
      hiddenAt: serializer.fromJson<DateTime>(json['hiddenAt']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'videoId': serializer.toJson<String>(videoId),
      'hiddenAt': serializer.toJson<DateTime>(hiddenAt),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  HiddenVideo copyWith({
    String? id,
    String? videoId,
    DateTime? hiddenAt,
    Value<String?> reason = const Value.absent(),
  }) => HiddenVideo(
    id: id ?? this.id,
    videoId: videoId ?? this.videoId,
    hiddenAt: hiddenAt ?? this.hiddenAt,
    reason: reason.present ? reason.value : this.reason,
  );
  HiddenVideo copyWithCompanion(HiddenVideosCompanion data) {
    return HiddenVideo(
      id: data.id.present ? data.id.value : this.id,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      hiddenAt: data.hiddenAt.present ? data.hiddenAt.value : this.hiddenAt,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HiddenVideo(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, videoId, hiddenAt, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HiddenVideo &&
          other.id == this.id &&
          other.videoId == this.videoId &&
          other.hiddenAt == this.hiddenAt &&
          other.reason == this.reason);
}

class HiddenVideosCompanion extends UpdateCompanion<HiddenVideo> {
  final Value<String> id;
  final Value<String> videoId;
  final Value<DateTime> hiddenAt;
  final Value<String?> reason;
  final Value<int> rowid;
  const HiddenVideosCompanion({
    this.id = const Value.absent(),
    this.videoId = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HiddenVideosCompanion.insert({
    required String id,
    required String videoId,
    required DateTime hiddenAt,
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       videoId = Value(videoId),
       hiddenAt = Value(hiddenAt);
  static Insertable<HiddenVideo> custom({
    Expression<String>? id,
    Expression<String>? videoId,
    Expression<DateTime>? hiddenAt,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoId != null) 'video_id': videoId,
      if (hiddenAt != null) 'hidden_at': hiddenAt,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HiddenVideosCompanion copyWith({
    Value<String>? id,
    Value<String>? videoId,
    Value<DateTime>? hiddenAt,
    Value<String?>? reason,
    Value<int>? rowid,
  }) {
    return HiddenVideosCompanion(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (hiddenAt.present) {
      map['hidden_at'] = Variable<DateTime>(hiddenAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenVideosCompanion(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideosTable videos = $VideosTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionVideosTable collectionVideos = $CollectionVideosTable(
    this,
  );
  late final $PlaybackHistoryTable playbackHistory = $PlaybackHistoryTable(
    this,
  );
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $HiddenVideosTable hiddenVideos = $HiddenVideosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    videos,
    collections,
    collectionVideos,
    playbackHistory,
    userPreferences,
    hiddenVideos,
  ];
}

typedef $$VideosTableCreateCompanionBuilder = VideosCompanion Function({
  required String id,
  required String filePath,
  required String title,
  Value<int> durationMs,
  Value<int> sizeBytes,
  required DateTime dateAdded,
  required DateTime dateModified,
  Value<String> mimeType,
  Value<int?> width,
  Value<int?> height,
  Value<String?> resolution,
  Value<int> lastPlayedPositionMs,
  Value<bool> isFavorite,
  Value<String?> thumbnailPath,
  Value<bool> isHidden,
  Value<int> rowid,
});
typedef $$VideosTableUpdateCompanionBuilder = VideosCompanion Function({
  Value<String> id,
  Value<String> filePath,
  Value<String> title,
  Value<int> durationMs,
  Value<int> sizeBytes,
  Value<DateTime> dateAdded,
  Value<DateTime> dateModified,
  Value<String> mimeType,
  Value<int?> width,
  Value<int?> height,
  Value<String?> resolution,
  Value<int> lastPlayedPositionMs,
  Value<bool> isFavorite,
  Value<String?> thumbnailPath,
  Value<bool> isHidden,
  Value<int> rowid,
});

class $$VideosTableFilterComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPlayedPositionMs => $composableBuilder(
    column: $table.lastPlayedPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideosTableOrderingComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPlayedPositionMs => $composableBuilder(
    column: $table.lastPlayedPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPlayedPositionMs => $composableBuilder(
    column: $table.lastPlayedPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);
}

class $$VideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideosTable,
          Video,
          $$VideosTableFilterComposer,
          $$VideosTableOrderingComposer,
          $$VideosTableAnnotationComposer,
          $$VideosTableCreateCompanionBuilder,
          $$VideosTableUpdateCompanionBuilder,
          (Video, BaseReferences<_$AppDatabase, $VideosTable, Video>),
          Video,
          PrefetchHooks Function()
        > {
  $$VideosTableTableManager(_$AppDatabase db, $VideosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<DateTime> dateModified = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> lastPlayedPositionMs = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosCompanion(
                id: id,
                filePath: filePath,
                title: title,
                durationMs: durationMs,
                sizeBytes: sizeBytes,
                dateAdded: dateAdded,
                dateModified: dateModified,
                mimeType: mimeType,
                width: width,
                height: height,
                resolution: resolution,
                lastPlayedPositionMs: lastPlayedPositionMs,
                isFavorite: isFavorite,
                thumbnailPath: thumbnailPath,
                isHidden: isHidden,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String filePath,
                required String title,
                Value<int> durationMs = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                required DateTime dateAdded,
                required DateTime dateModified,
                Value<String> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> lastPlayedPositionMs = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosCompanion.insert(
                id: id,
                filePath: filePath,
                title: title,
                durationMs: durationMs,
                sizeBytes: sizeBytes,
                dateAdded: dateAdded,
                dateModified: dateModified,
                mimeType: mimeType,
                width: width,
                height: height,
                resolution: resolution,
                lastPlayedPositionMs: lastPlayedPositionMs,
                isFavorite: isFavorite,
                thumbnailPath: thumbnailPath,
                isHidden: isHidden,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VideosTable, Video>(table),
                  BaseReferences<_$AppDatabase, $VideosTable, Video>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideosTable,
      Video,
      $$VideosTableFilterComposer,
      $$VideosTableOrderingComposer,
      $$VideosTableAnnotationComposer,
      $$VideosTableCreateCompanionBuilder,
      $$VideosTableUpdateCompanionBuilder,
      (Video, BaseReferences<_$AppDatabase, $VideosTable, Video>),
      Video,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> coverVideoId,
      Value<bool> isSmartCollection,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> coverVideoId,
      Value<bool> isSmartCollection,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverVideoId => $composableBuilder(
    column: $table.coverVideoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSmartCollection => $composableBuilder(
    column: $table.isSmartCollection,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverVideoId => $composableBuilder(
    column: $table.coverVideoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSmartCollection => $composableBuilder(
    column: $table.isSmartCollection,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get coverVideoId => $composableBuilder(
    column: $table.coverVideoId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSmartCollection => $composableBuilder(
    column: $table.isSmartCollection,
    builder: (column) => column,
  );
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            Collection,
            BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
          ),
          Collection,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> coverVideoId = const Value.absent(),
                Value<bool> isSmartCollection = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                coverVideoId: coverVideoId,
                isSmartCollection: isSmartCollection,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> coverVideoId = const Value.absent(),
                Value<bool> isSmartCollection = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                coverVideoId: coverVideoId,
                isSmartCollection: isSmartCollection,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, Collection>(table),
                  BaseReferences<_$AppDatabase, $CollectionsTable, Collection>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        Collection,
        BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
      ),
      Collection,
      PrefetchHooks Function()
    >;
typedef $$CollectionVideosTableCreateCompanionBuilder =
    CollectionVideosCompanion Function({
      required String id,
      required String collectionId,
      required String videoId,
      Value<int> orderIndex,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$CollectionVideosTableUpdateCompanionBuilder =
    CollectionVideosCompanion Function({
      Value<String> id,
      Value<String> collectionId,
      Value<String> videoId,
      Value<int> orderIndex,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$CollectionVideosTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionVideosTable> {
  $$CollectionVideosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionVideosTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionVideosTable> {
  $$CollectionVideosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionVideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionVideosTable> {
  $$CollectionVideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$CollectionVideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionVideosTable,
          CollectionVideo,
          $$CollectionVideosTableFilterComposer,
          $$CollectionVideosTableOrderingComposer,
          $$CollectionVideosTableAnnotationComposer,
          $$CollectionVideosTableCreateCompanionBuilder,
          $$CollectionVideosTableUpdateCompanionBuilder,
          (
            CollectionVideo,
            BaseReferences<
              _$AppDatabase,
              $CollectionVideosTable,
              CollectionVideo
            >,
          ),
          CollectionVideo,
          PrefetchHooks Function()
        > {
  $$CollectionVideosTableTableManager(
    _$AppDatabase db,
    $CollectionVideosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionVideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionVideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionVideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionVideosCompanion(
                id: id,
                collectionId: collectionId,
                videoId: videoId,
                orderIndex: orderIndex,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String collectionId,
                required String videoId,
                Value<int> orderIndex = const Value.absent(),
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionVideosCompanion.insert(
                id: id,
                collectionId: collectionId,
                videoId: videoId,
                orderIndex: orderIndex,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionVideosTable, CollectionVideo>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CollectionVideosTable,
                    CollectionVideo
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionVideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionVideosTable,
      CollectionVideo,
      $$CollectionVideosTableFilterComposer,
      $$CollectionVideosTableOrderingComposer,
      $$CollectionVideosTableAnnotationComposer,
      $$CollectionVideosTableCreateCompanionBuilder,
      $$CollectionVideosTableUpdateCompanionBuilder,
      (
        CollectionVideo,
        BaseReferences<_$AppDatabase, $CollectionVideosTable, CollectionVideo>,
      ),
      CollectionVideo,
      PrefetchHooks Function()
    >;
typedef $$PlaybackHistoryTableCreateCompanionBuilder =
    PlaybackHistoryCompanion Function({
      required String id,
      required String videoId,
      required DateTime playedAt,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> completed,
      Value<int> rowid,
    });
typedef $$PlaybackHistoryTableUpdateCompanionBuilder =
    PlaybackHistoryCompanion Function({
      Value<String> id,
      Value<String> videoId,
      Value<DateTime> playedAt,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> completed,
      Value<int> rowid,
    });

class $$PlaybackHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryTable> {
  $$PlaybackHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryTable> {
  $$PlaybackHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackHistoryTable> {
  $$PlaybackHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$PlaybackHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackHistoryTable,
          PlaybackHistoryData,
          $$PlaybackHistoryTableFilterComposer,
          $$PlaybackHistoryTableOrderingComposer,
          $$PlaybackHistoryTableAnnotationComposer,
          $$PlaybackHistoryTableCreateCompanionBuilder,
          $$PlaybackHistoryTableUpdateCompanionBuilder,
          (
            PlaybackHistoryData,
            BaseReferences<
              _$AppDatabase,
              $PlaybackHistoryTable,
              PlaybackHistoryData
            >,
          ),
          PlaybackHistoryData,
          PrefetchHooks Function()
        > {
  $$PlaybackHistoryTableTableManager(
    _$AppDatabase db,
    $PlaybackHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackHistoryCompanion(
                id: id,
                videoId: videoId,
                playedAt: playedAt,
                positionMs: positionMs,
                durationMs: durationMs,
                completed: completed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String videoId,
                required DateTime playedAt,
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackHistoryCompanion.insert(
                id: id,
                videoId: videoId,
                playedAt: playedAt,
                positionMs: positionMs,
                durationMs: durationMs,
                completed: completed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaybackHistoryTable, PlaybackHistoryData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaybackHistoryTable,
                    PlaybackHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackHistoryTable,
      PlaybackHistoryData,
      $$PlaybackHistoryTableFilterComposer,
      $$PlaybackHistoryTableOrderingComposer,
      $$PlaybackHistoryTableAnnotationComposer,
      $$PlaybackHistoryTableCreateCompanionBuilder,
      $$PlaybackHistoryTableUpdateCompanionBuilder,
      (
        PlaybackHistoryData,
        BaseReferences<
          _$AppDatabase,
          $PlaybackHistoryTable,
          PlaybackHistoryData
        >,
      ),
      PlaybackHistoryData,
      PrefetchHooks Function()
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserPreferencesTable, UserPreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserPreferencesTable,
                    UserPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;
typedef $$HiddenVideosTableCreateCompanionBuilder =
    HiddenVideosCompanion Function({
      required String id,
      required String videoId,
      required DateTime hiddenAt,
      Value<String?> reason,
      Value<int> rowid,
    });
typedef $$HiddenVideosTableUpdateCompanionBuilder =
    HiddenVideosCompanion Function({
      Value<String> id,
      Value<String> videoId,
      Value<DateTime> hiddenAt,
      Value<String?> reason,
      Value<int> rowid,
    });

class $$HiddenVideosTableFilterComposer
    extends Composer<_$AppDatabase, $HiddenVideosTable> {
  $$HiddenVideosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hiddenAt => $composableBuilder(
    column: $table.hiddenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HiddenVideosTableOrderingComposer
    extends Composer<_$AppDatabase, $HiddenVideosTable> {
  $$HiddenVideosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hiddenAt => $composableBuilder(
    column: $table.hiddenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HiddenVideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HiddenVideosTable> {
  $$HiddenVideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<DateTime> get hiddenAt =>
      $composableBuilder(column: $table.hiddenAt, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$HiddenVideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HiddenVideosTable,
          HiddenVideo,
          $$HiddenVideosTableFilterComposer,
          $$HiddenVideosTableOrderingComposer,
          $$HiddenVideosTableAnnotationComposer,
          $$HiddenVideosTableCreateCompanionBuilder,
          $$HiddenVideosTableUpdateCompanionBuilder,
          (
            HiddenVideo,
            BaseReferences<_$AppDatabase, $HiddenVideosTable, HiddenVideo>,
          ),
          HiddenVideo,
          PrefetchHooks Function()
        > {
  $$HiddenVideosTableTableManager(_$AppDatabase db, $HiddenVideosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HiddenVideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HiddenVideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HiddenVideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<DateTime> hiddenAt = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HiddenVideosCompanion(
                id: id,
                videoId: videoId,
                hiddenAt: hiddenAt,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String videoId,
                required DateTime hiddenAt,
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HiddenVideosCompanion.insert(
                id: id,
                videoId: videoId,
                hiddenAt: hiddenAt,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HiddenVideosTable, HiddenVideo>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HiddenVideosTable,
                    HiddenVideo
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HiddenVideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HiddenVideosTable,
      HiddenVideo,
      $$HiddenVideosTableFilterComposer,
      $$HiddenVideosTableOrderingComposer,
      $$HiddenVideosTableAnnotationComposer,
      $$HiddenVideosTableCreateCompanionBuilder,
      $$HiddenVideosTableUpdateCompanionBuilder,
      (
        HiddenVideo,
        BaseReferences<_$AppDatabase, $HiddenVideosTable, HiddenVideo>,
      ),
      HiddenVideo,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideosTableTableManager get videos =>
      $$VideosTableTableManager(_db, _db.videos);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionVideosTableTableManager get collectionVideos =>
      $$CollectionVideosTableTableManager(_db, _db.collectionVideos);
  $$PlaybackHistoryTableTableManager get playbackHistory =>
      $$PlaybackHistoryTableTableManager(_db, _db.playbackHistory);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$HiddenVideosTableTableManager get hiddenVideos =>
      $$HiddenVideosTableTableManager(_db, _db.hiddenVideos);
}
