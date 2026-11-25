import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subtitle_parser.dart';

/// Represents an audio track in the active media item
class AudioTrackInfo {
  final String id;
  final int groupIndex;
  final int trackIndex;
  final String label;
  final String language;
  final String langCode;
  final String codec;
  final String channels;
  final int bitrate;
  final bool isSelected;
  final bool isSupported;

  const AudioTrackInfo({
    required this.id,
    required this.groupIndex,
    required this.trackIndex,
    required this.label,
    required this.language,
    required this.langCode,
    required this.codec,
    required this.channels,
    required this.bitrate,
    required this.isSelected,
    required this.isSupported,
  });

  factory AudioTrackInfo.fromMap(Map<dynamic, dynamic> map) {
    return AudioTrackInfo(
      id: map['id']?.toString() ?? '',
      groupIndex: (map['groupIndex'] as num?)?.toInt() ?? 0,
      trackIndex: (map['trackIndex'] as num?)?.toInt() ?? 0,
      label: map['label']?.toString() ?? '',
      language: map['language']?.toString() ?? '',
      langCode: map['langCode']?.toString() ?? '',
      codec: map['codec']?.toString() ?? 'Unknown',
      channels: map['channels']?.toString() ?? '',
      bitrate: (map['bitrate'] as num?)?.toInt() ?? 0,
      isSelected: map['isSelected'] as bool? ?? false,
      isSupported: map['isSupported'] as bool? ?? true,
    );
  }

  /// Formatted title following "Language — Codec Channels"
  String get displayTitle {
    final titlePart = language.isNotEmpty ? language : (label.isNotEmpty ? label : 'Audio Track');
    final details = <String>[];
    if (codec.isNotEmpty && codec != 'Unknown') details.add(codec);
    if (channels.isNotEmpty) details.add(channels);

    if (details.isNotEmpty) {
      return '$titlePart — ${details.join(' ')}';
    }
    return titlePart;
  }

  @override
  String toString() => 'AudioTrackInfo($displayTitle, selected: $isSelected)';
}

/// Represents a subtitle track (embedded or external)
class SubtitleTrackInfo {
  final String id;
  final int groupIndex;
  final int trackIndex;
  final String label;
  final String language;
  final String langCode;
  final String mimeType;
  final bool isSelected;
  final bool isExternal;
  final String? filePath;
  final List<SubtitleCue>? cues;

  const SubtitleTrackInfo({
    required this.id,
    required this.groupIndex,
    required this.trackIndex,
    required this.label,
    required this.language,
    required this.langCode,
    required this.mimeType,
    required this.isSelected,
    this.isExternal = false,
    this.filePath,
    this.cues,
  });

  factory SubtitleTrackInfo.fromMap(Map<dynamic, dynamic> map) {
    return SubtitleTrackInfo(
      id: map['id']?.toString() ?? '',
      groupIndex: (map['groupIndex'] as num?)?.toInt() ?? 0,
      trackIndex: (map['trackIndex'] as num?)?.toInt() ?? 0,
      label: map['label']?.toString() ?? '',
      language: map['language']?.toString() ?? '',
      langCode: map['langCode']?.toString() ?? '',
      mimeType: map['mimeType']?.toString() ?? '',
      isSelected: map['isSelected'] as bool? ?? false,
      isExternal: map['isExternal'] as bool? ?? false,
    );
  }

  SubtitleTrackInfo copyWith({
    String? id,
    int? groupIndex,
    int? trackIndex,
    String? label,
    String? language,
    String? langCode,
    String? mimeType,
    bool? isSelected,
    bool? isExternal,
    String? filePath,
    List<SubtitleCue>? cues,
  }) {
    return SubtitleTrackInfo(
      id: id ?? this.id,
      groupIndex: groupIndex ?? this.groupIndex,
      trackIndex: trackIndex ?? this.trackIndex,
      label: label ?? this.label,
      language: language ?? this.language,
      langCode: langCode ?? this.langCode,
      mimeType: mimeType ?? this.mimeType,
      isSelected: isSelected ?? this.isSelected,
      isExternal: isExternal ?? this.isExternal,
      filePath: filePath ?? this.filePath,
      cues: cues ?? this.cues,
    );
  }

  String get displayTitle {
    if (isExternal) {
      return '$label (External)';
    }
    if (language.isNotEmpty) {
      return language;
    }
    if (label.isNotEmpty) {
      return label;
    }
    return 'Subtitle Track';
  }

  @override
  String toString() => 'SubtitleTrackInfo($displayTitle, selected: $isSelected, external: $isExternal)';
}

/// Custom visual styling and delay configuration for subtitles
class SubtitleStyle {
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final double bottomMargin;
  final int delayMs;

  const SubtitleStyle({
    this.fontSize = 18.0,
    this.textColor = Colors.white,
    this.backgroundColor = const Color(0xB3000000), // 70% black
    this.bottomMargin = 72.0,
    this.delayMs = 0,
  });

  SubtitleStyle copyWith({
    double? fontSize,
    Color? textColor,
    Color? backgroundColor,
    double? bottomMargin,
    int? delayMs,
  }) {
    return SubtitleStyle(
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      bottomMargin: bottomMargin ?? this.bottomMargin,
      delayMs: delayMs ?? this.delayMs,
    );
  }
}

/// Service bridge to native Android Media3 for Audio & Subtitle track controls
class MediaTracksService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/tracks');

  final StreamController<String> _subtitleCueController = StreamController<String>.broadcast();
  final StreamController<void> _tracksChangedController = StreamController<void>.broadcast();

  Stream<String> get subtitleCueStream => _subtitleCueController.stream;
  Stream<void> get tracksChangedStream => _tracksChangedController.stream;

  MediaTracksService() {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSubtitleCue':
        final text = (call.arguments as Map?)?['text']?.toString() ?? '';
        _subtitleCueController.add(text);
        break;
      case 'onTracksChanged':
        _tracksChangedController.add(null);
        break;
    }
  }

  /// Retrieve all available audio tracks in the currently playing video
  Future<List<AudioTrackInfo>> getAudioTracks() async {
    try {
      final result = await _channel.invokeListMethod<dynamic>('getAudioTracks');
      if (result == null) return [];
      return result
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => AudioTrackInfo.fromMap(m))
          .toList();
    } on PlatformException catch (e) {
      debugPrint('[MediaTracksService] Failed to get audio tracks: ${e.message}');
      return [];
    }
  }

  /// Select a specific audio track
  Future<bool> selectAudioTrack(int groupIndex, int trackIndex) async {
    try {
      final success = await _channel.invokeMethod<bool>('selectAudioTrack', {
        'groupIndex': groupIndex,
        'trackIndex': trackIndex,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('[MediaTracksService] Failed to select audio track: ${e.message}');
      return false;
    }
  }

  /// Reset audio track to Auto / Default
  Future<bool> resetAudioTrack() async {
    try {
      final success = await _channel.invokeMethod<bool>('resetAudioTrack');
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('[MediaTracksService] Failed to reset audio track: ${e.message}');
      return false;
    }
  }

  /// Retrieve all embedded subtitle tracks
  Future<List<SubtitleTrackInfo>> getSubtitleTracks() async {
    try {
      final result = await _channel.invokeListMethod<dynamic>('getSubtitleTracks');
      if (result == null) return [];
      return result
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => SubtitleTrackInfo.fromMap(m))
          .toList();
    } on PlatformException catch (e) {
      debugPrint('[MediaTracksService] Failed to get subtitle tracks: ${e.message}');
      return [];
    }
  }

  /// Select an embedded subtitle track
  Future<bool> selectSubtitleTrack(int groupIndex, int trackIndex) async {
    try {
      final success = await _channel.invokeMethod<bool>('selectSubtitleTrack', {
        'groupIndex': groupIndex,
        'trackIndex': trackIndex,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('[MediaTracksService] Failed to select subtitle track: ${e.message}');
      return false;
    }
  }

  /// Disable all subtitles
  Future<bool> disableSubtitles() async {
    try {
      final success = await _channel.invokeMethod<bool>('disableSubtitles');
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('[MediaTracksService] Failed to disable subtitles: ${e.message}');
      return false;
    }
  }

  /// Open Android Storage Access Framework picker for .srt, .vtt, .ass, .ssa
  Future<Map<String, dynamic>?> pickSubtitleFile() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('pickSubtitleFile');
      return result;
    } on PlatformException catch (e) {
      debugPrint('[MediaTracksService] Failed to pick subtitle file: ${e.message}');
      return null;
    }
  }

  void dispose() {
    _subtitleCueController.close();
    _tracksChangedController.close();
  }
}

final mediaTracksServiceProvider = Provider<MediaTracksService>((ref) {
  final service = MediaTracksService();
  ref.onDispose(() => service.dispose());
  return service;
});
