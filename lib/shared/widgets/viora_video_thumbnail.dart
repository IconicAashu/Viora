import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/services/video_discovery_service.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/theme/viora_icons.dart';

/// Reusable, high-performance video thumbnail widget for VIORA.
///
/// Features:
/// 1. Immediately displays cached thumbnail if available on disk.
/// 2. Asynchronously requests thumbnail extraction via native MediaStore / MediaMetadataRetriever
///    if the thumbnail is missing or pending.
/// 3. Updates Drift database so future viewings load instantly.
/// 4. Handles concurrency and avoids redundant jobs using an in-memory task map.
/// 5. Gracefully handles deleted, moved, or corrupted videos with the brand purple placeholder.
class VioraVideoThumbnail extends ConsumerStatefulWidget {
  const VioraVideoThumbnail({
    super.key,
    required this.video,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIconSize = 36.0,
  });

  final Video video;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double fallbackIconSize;

  // In-flight extraction tracker to prevent redundant jobs
  static final Set<String> _pendingExtraction = <String>{};

  @override
  ConsumerState<VioraVideoThumbnail> createState() => _VioraVideoThumbnailState();
}

class _VioraVideoThumbnailState extends ConsumerState<VioraVideoThumbnail> {
  String? _resolvedThumbnailPath;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _checkAndResolveThumbnail();
  }

  @override
  void didUpdateWidget(covariant VioraVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id ||
        oldWidget.video.thumbnailPath != widget.video.thumbnailPath) {
      _checkAndResolveThumbnail();
    }
  }

  void _checkAndResolveThumbnail() {
    final existingPath = widget.video.thumbnailPath;
    if (existingPath != null && existingPath.isNotEmpty && File(existingPath).existsSync()) {
      _resolvedThumbnailPath = existingPath;
      return;
    }

    _resolvedThumbnailPath = null;
    _triggerAsyncGeneration();
  }

  Future<void> _triggerAsyncGeneration() async {
    final videoId = widget.video.id;
    final filePath = widget.video.filePath;

    if (videoId.isEmpty || VioraVideoThumbnail._pendingExtraction.contains(videoId)) {
      return;
    }

    VioraVideoThumbnail._pendingExtraction.add(videoId);
    if (mounted) setState(() => _isGenerating = true);

    try {
      final discovery = ref.read(videoDiscoveryServiceProvider);
      final thumbPath = await discovery.generateThumbnail(
        filePath: filePath,
        videoId: videoId,
      );

      if (thumbPath != null && File(thumbPath).existsSync()) {
        // Update database asynchronously
        final db = ref.read(appDatabaseProvider);
        await (db.update(db.videos)..where((tbl) => tbl.id.equals(videoId))).write(
          VideosCompanion(thumbnailPath: Value(thumbPath)),
        );

        if (mounted) {
          setState(() {
            _resolvedThumbnailPath = thumbPath;
            _isGenerating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isGenerating = false);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    } finally {
      VioraVideoThumbnail._pendingExtraction.remove(videoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final path = _resolvedThumbnailPath;

    Widget content;
    if (path != null && File(path).existsSync()) {
      content = Image.file(
        File(path),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => _buildFallback(colors),
      );
    } else if (_isGenerating) {
      content = Container(
        color: colors.surfaceSecondary,
        width: widget.width,
        height: widget.height,
        child: Center(
          child: SizedBox(
            width: widget.fallbackIconSize * 0.6,
            height: widget.fallbackIconSize * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: colors.accent.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    } else {
      content = _buildFallback(colors);
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildFallback(dynamic colors) {
    return Container(
      color: colors.surfaceSecondary,
      width: widget.width,
      height: widget.height,
      child: Center(
        child: Icon(
          VioraIcons.video,
          color: colors.accent,
          size: widget.fallbackIconSize,
        ),
      ),
    );
  }
}
