import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/services/media_tracks_service.dart';
import '../../../core/services/picture_in_picture_service.dart';
import '../../../core/services/player_controls_service.dart';
import '../../../core/services/subtitle_parser.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/formatters.dart';

enum PlayerAspectRatio {
  fit('Fit'),
  fill('Fill'),
  sixteenNine('16:9'),
  fourThree('4:3'),
  original('Original');

  const PlayerAspectRatio(this.label);
  final String label;
}

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.playlist,
    this.initialIndex,
  });

  final Video video;
  final List<Video>? playlist;
  final int? initialIndex;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late Video _currentVideo;
  late int _currentIndex;
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  // UI state
  bool _showControls = true;
  bool _isControlsLocked = false;
  bool _showLockIndicator = false;
  Timer? _lockIndicatorTimer;
  Timer? _hideControlsTimer;
  PlayerAspectRatio _aspectRatioMode = PlayerAspectRatio.fit;
  double _playbackSpeed = 1.0;

  // Seekbar interactive state
  bool _isDraggingSeekbar = false;
  double _dragPositionMs = 0.0;
  Timer? _seekDebounceTimer;

  // Swipe gesture feedback
  double? _gestureBrightness;
  double? _gestureVolume;
  bool _showGestureOverlay = false;
  String _gestureOverlayText = '';
  IconData _gestureOverlayIcon = VioraIcons.brightness;
  Timer? _gestureOverlayTimer;

  // Double tap seek animation indicators
  bool _showSeekLeft = false;
  bool _showSeekRight = false;
  Timer? _seekAnimTimer;

  // Progress save timer
  Timer? _progressSaveTimer;

  // Play/Pause icon animation controller
  late final AnimationController _playPauseAnimController;

  // Audio Tracks and Subtitles
  List<AudioTrackInfo> _audioTracks = [];
  AudioTrackInfo? _selectedAudioTrack;
  bool _isAutoAudio = true;

  bool _subtitlesEnabled = false;
  List<SubtitleTrackInfo> _subtitleTracks = [];
  SubtitleTrackInfo? _selectedSubtitleTrack;
  String _currentSubtitleText = '';
  SubtitleStyle _subtitleStyle = const SubtitleStyle();
  StreamSubscription<String>? _subtitleCueSub;
  StreamSubscription<void>? _tracksChangedSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentVideo = widget.video;
    _currentIndex = widget.initialIndex ??
        (widget.playlist?.indexWhere((v) => v.id == widget.video.id) ?? 0);
    if (_currentIndex < 0) _currentIndex = 0;

    _playPauseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    final tracksService = ref.read(mediaTracksServiceProvider);
    _tracksChangedSub = tracksService.tracksChangedStream.listen((_) {
      if (mounted) _loadAvailableTracks();
    });
    _subtitleCueSub = tracksService.subtitleCueStream.listen((cue) {
      if (mounted && _subtitlesEnabled && (_selectedSubtitleTrack == null || !_selectedSubtitleTrack!.isExternal)) {
        setState(() {
          _currentSubtitleText = cue;
        });
      }
    });

    _enterImmersiveMode();
    _initializePlayer();
  }

  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitPlayer() {
    // Restore preferred orientation to standard portrait for the main app
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    // Check external subtitle timing
    if (_subtitlesEnabled &&
        _selectedSubtitleTrack?.isExternal == true &&
        _selectedSubtitleTrack?.cues != null &&
        _selectedSubtitleTrack!.cues!.isNotEmpty) {
      final posMs = (_controller?.value.position.inMilliseconds ?? 0) + _subtitleStyle.delayMs;
      final cue = SubtitleParser.getActiveCueText(_selectedSubtitleTrack!.cues!, posMs) ?? '';
      if (cue != _currentSubtitleText) {
        setState(() {
          _currentSubtitleText = cue;
        });
      }
    }

    // Live UI updates for seekbar and timestamps when controls are visible and user is not dragging
    if (_showControls && !_isDraggingSeekbar) {
      setState(() {});
    }
  }

  bool _isVideoLandscape(VideoPlayerController controller) {
    final size = controller.value.size;
    final rot = controller.value.rotationCorrection;
    if (size.width == 0 || size.height == 0) {
      final w = _currentVideo.width ?? 0;
      final h = _currentVideo.height ?? 0;
      return w > h;
    }
    // Swap width and height if rotated by 90 or 270 degrees
    final effectiveWidth = (rot == 90 || rot == 270) ? size.height : size.width;
    final effectiveHeight = (rot == 90 || rot == 270) ? size.width : size.height;
    return effectiveWidth > effectiveHeight;
  }

  void _applyInitialOrientation(VideoPlayerController controller) {
    if (_isVideoLandscape(controller)) {
      // Landscape video: lock preferred orientation to landscape
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Portrait video: lock preferred orientation to portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _toggleManualOrientation() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    _startHideTimer();
  }

  Future<void> _initializePlayer() async {
    _isInitialized = false;
    _hasError = false;
    setState(() {});

    final oldController = _controller;
    _controller = null;
    oldController?.removeListener(_onControllerUpdate);
    await oldController?.dispose();

    try {
      final file = File(_currentVideo.filePath);
      if (!await file.exists()) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Video file not found or inaccessible.';
        });
        return;
      }

      final controller = VideoPlayerController.file(file);
      await controller.initialize();

      // Configure orientation to match the video's actual dimensions
      _applyInitialOrientation(controller);

      // Auto-resume if last played position is valid (> 5s and < duration - 10s)
      final resumeMs = _currentVideo.lastPlayedPositionMs;
      final totalMs = controller.value.duration.inMilliseconds;
      if (resumeMs > 5000 && resumeMs < totalMs - 10000) {
        await controller.seekTo(Duration(milliseconds: resumeMs));
      }

      await controller.setPlaybackSpeed(_playbackSpeed);
      await controller.play();
      _playPauseAnimController.forward();

      // Attach listener for real-time progress updates
      controller.addListener(_onControllerUpdate);

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isInitialized = true;
      });

      _loadAvailableTracks();

      _startHideTimer();
      _startProgressSaveTimer();
      _recordPlaybackHistory();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Playback error: $e';
      });
    }
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    if (_isControlsLocked || _isDraggingSeekbar) return;

    // Controls only auto-hide when the video is currently playing
    if (_controller?.value.isPlaying == true) {
      _hideControlsTimer = Timer(const Duration(milliseconds: 3500), () {
        if (mounted && _controller?.value.isPlaying == true && !_isDraggingSeekbar) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _triggerTemporaryLockIndicator() {
    _lockIndicatorTimer?.cancel();
    setState(() {
      _showLockIndicator = true;
    });
    _lockIndicatorTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showLockIndicator = false;
        });
      }
    });
  }

  void _lockControls() {
    _hideControlsTimer?.cancel();
    setState(() {
      _isControlsLocked = true;
      _showControls = false;
    });
    _triggerTemporaryLockIndicator();
  }

  void _unlockControls() {
    _lockIndicatorTimer?.cancel();
    setState(() {
      _isControlsLocked = false;
      _showLockIndicator = false;
      _showControls = true;
    });
    _startHideTimer();
  }

  void _onVideoAreaTap() {
    if (_isControlsLocked) {
      _triggerTemporaryLockIndicator();
      return;
    }

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
      _playPauseAnimController.reverse();
      // Keep controls visible while paused
      _hideControlsTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      controller.play();
      _playPauseAnimController.forward();
      _startHideTimer();
      setState(() {});
    }
  }

  void _startProgressSaveTimer() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _saveCurrentPosition();
    });
  }

  Future<void> _saveCurrentPosition() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final posMs = controller.value.position.inMilliseconds;
    final db = ref.read(appDatabaseProvider);
    try {
      await (db.update(db.videos)..where((tbl) => tbl.id.equals(_currentVideo.id))).write(
        VideosCompanion(
          lastPlayedPositionMs: Value(posMs),
        ),
      );
    } catch (_) {}
  }

  Future<void> _recordPlaybackHistory() async {
    final controller = _controller;
    if (controller == null) return;
    final db = ref.read(appDatabaseProvider);
    try {
      await db.into(db.playbackHistory).insert(
            PlaybackHistoryCompanion.insert(
              id: '${_currentVideo.id}_${DateTime.now().millisecondsSinceEpoch}',
              videoId: _currentVideo.id,
              playedAt: DateTime.now(),
              positionMs: Value(controller.value.position.inMilliseconds),
              durationMs: Value(controller.value.duration.inMilliseconds),
            ),
          );
    } catch (_) {}
  }

  void _seekRelative(int seconds) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final currentPos = controller.value.position;
    final newPos = currentPos + Duration(seconds: seconds);
    final clamped = Duration(
      milliseconds: newPos.inMilliseconds.clamp(0, controller.value.duration.inMilliseconds),
    );
    controller.seekTo(clamped);

    _seekAnimTimer?.cancel();
    setState(() {
      if (seconds < 0) {
        _showSeekLeft = true;
        _showSeekRight = false;
      } else {
        _showSeekRight = true;
        _showSeekLeft = false;
      }
    });

    _seekAnimTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showSeekLeft = false;
          _showSeekRight = false;
        });
      }
    });

    _startHideTimer();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details, double screenWidth) {
    if (_isControlsLocked) return;
    final isLeft = details.globalPosition.dx < screenWidth / 2;
    final delta = -details.primaryDelta! / 250.0;

    final service = ref.read(playerControlsServiceProvider);
    if (isLeft) {
      _gestureBrightness = ((_gestureBrightness ?? 0.5) + delta).clamp(0.01, 1.0);
      service.setBrightness(_gestureBrightness!);
      _showOverlay(
        icon: VioraIcons.brightness,
        text: 'Brightness ${(_gestureBrightness! * 100).round()}%',
      );
    } else {
      _gestureVolume = ((_gestureVolume ?? 0.5) + delta).clamp(0.0, 1.0);
      service.setVolume(_gestureVolume!);
      _showOverlay(
        icon: _gestureVolume! == 0 ? VioraIcons.volumeMute : VioraIcons.volumeHigh,
        text: 'Volume ${(_gestureVolume! * 100).round()}%',
      );
    }
  }

  void _showOverlay({required IconData icon, required String text}) {
    _gestureOverlayTimer?.cancel();
    setState(() {
      _showGestureOverlay = true;
      _gestureOverlayIcon = icon;
      _gestureOverlayText = text;
    });
    _gestureOverlayTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showGestureOverlay = false);
    });
  }

  void _playNext() {
    final playlist = widget.playlist;
    if (playlist != null && _currentIndex < playlist.length - 1) {
      _currentIndex++;
      _currentVideo = playlist[_currentIndex];
      _initializePlayer();
    }
  }

  void _playPrevious() {
    final playlist = widget.playlist;
    if (playlist != null && _currentIndex > 0) {
      _currentIndex--;
      _currentVideo = playlist[_currentIndex];
      _initializePlayer();
    }
  }

  void _cycleAspectRatio() {
    final nextIndex = (_aspectRatioMode.index + 1) % PlayerAspectRatio.values.length;
    setState(() {
      _aspectRatioMode = PlayerAspectRatio.values[nextIndex];
    });
    _showOverlay(
      icon: VioraIcons.aspectRatio,
      text: 'Aspect Ratio: ${_aspectRatioMode.label}',
    );
    _startHideTimer();
  }

  Future<void> _loadAvailableTracks() async {
    try {
      final tracksService = ref.read(mediaTracksServiceProvider);
      final audios = await tracksService.getAudioTracks();
      final subs = await tracksService.getSubtitleTracks();

      if (!mounted) return;
      setState(() {
        _audioTracks = audios;
        final externalSubs = _subtitleTracks.where((s) => s.isExternal).toList();
        _subtitleTracks = [...subs, ...externalSubs];

        final activeAudio = audios.where((a) => a.isSelected).firstOrNull;
        if (activeAudio != null) {
          _selectedAudioTrack = activeAudio;
        }

        if (_selectedSubtitleTrack == null || !_selectedSubtitleTrack!.isExternal) {
          final activeSub = subs.where((s) => s.isSelected).firstOrNull;
          if (activeSub != null) {
            _selectedSubtitleTrack = activeSub;
            _subtitlesEnabled = true;
          }
        }
      });
    } catch (e) {
      debugPrint('[VideoPlayerScreen] Error loading tracks: $e');
    }
  }

  Future<void> _selectAudioTrack(AudioTrackInfo? track) async {
    final tracksService = ref.read(mediaTracksServiceProvider);
    if (track == null) {
      await tracksService.resetAudioTrack();
      setState(() {
        _isAutoAudio = true;
        _selectedAudioTrack = null;
      });
    } else {
      await tracksService.selectAudioTrack(track.groupIndex, track.trackIndex);
      setState(() {
        _isAutoAudio = false;
        _selectedAudioTrack = track;
      });
    }
    await _loadAvailableTracks();
  }

  Future<void> _selectSubtitleTrack(SubtitleTrackInfo? track) async {
    final tracksService = ref.read(mediaTracksServiceProvider);
    if (track == null) {
      await tracksService.disableSubtitles();
      setState(() {
        _subtitlesEnabled = false;
        _selectedSubtitleTrack = null;
        _currentSubtitleText = '';
      });
    } else if (track.isExternal) {
      await tracksService.disableSubtitles();
      setState(() {
        _subtitlesEnabled = true;
        _selectedSubtitleTrack = track;
        _currentSubtitleText = '';
      });
    } else {
      await tracksService.selectSubtitleTrack(track.groupIndex, track.trackIndex);
      setState(() {
        _subtitlesEnabled = true;
        _selectedSubtitleTrack = track;
        _currentSubtitleText = '';
      });
    }
  }

  Future<void> _pickExternalSubtitle() async {
    final tracksService = ref.read(mediaTracksServiceProvider);
    final result = await tracksService.pickSubtitleFile();
    if (result != null && result['content'] != null) {
      final fileName = result['fileName'] as String? ?? 'External Subtitle';
      final content = result['content'] as String? ?? '';
      final uri = result['uri'] as String? ?? '';

      final ext = fileName.contains('.') ? fileName.split('.').last : null;
      final cues = SubtitleParser.parse(content, extension: ext);

      final newTrack = SubtitleTrackInfo(
        id: 'ext_${DateTime.now().millisecondsSinceEpoch}',
        groupIndex: -1,
        trackIndex: -1,
        label: fileName,
        language: 'External',
        langCode: '',
        mimeType: 'text/plain',
        isSelected: true,
        isExternal: true,
        filePath: uri,
        cues: cues,
      );

      setState(() {
        _subtitleTracks.add(newTrack);
        _selectedSubtitleTrack = newTrack;
        _subtitlesEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded subtitle: $fileName (${cues.length} cues)'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colors.accent.withValues(alpha: 0.2),
      backgroundColor: colors.surfaceSecondary,
      labelStyle: TextStyle(
        color: isSelected ? colors.accent : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? colors.accent : Colors.transparent,
        width: 1.5,
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildColorDot(Color color, String tooltip, StateSetter setSheetState) {
    final isSelected = _subtitleStyle.textColor == color;
    return GestureDetector(
      onTap: () {
        setState(() => _subtitleStyle = _subtitleStyle.copyWith(textColor: color));
        setSheetState(() {});
      },
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? context.colors.accent : Colors.white24,
              width: isSelected ? 2.5 : 1.0,
            ),
          ),
          child: isSelected
              ? Icon(
                  VioraIcons.check,
                  size: 16,
                  color: color == Colors.white ? Colors.black : Colors.white,
                )
              : null,
        ),
      ),
    );
  }

  void _showAudioTrackSheet() {
    _hideControlsTimer?.cancel();
    final colors = context.colors;
    final typography = context.typography;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Audio Track', style: typography.headline),
                        IconButton(
                          icon: const Icon(VioraIcons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        VioraIcons.sparkles,
                        color: _isAutoAudio ? colors.accent : colors.textSecondary,
                        size: 20,
                      ),
                      title: Text(
                        'Auto / Default',
                        style: typography.body.copyWith(
                          fontWeight: _isAutoAudio ? FontWeight.bold : FontWeight.normal,
                          color: _isAutoAudio ? colors.accent : colors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically selects optimal audio track',
                        style: typography.footnote,
                      ),
                      trailing: _isAutoAudio
                          ? Icon(VioraIcons.check, color: colors.accent, size: 20)
                          : null,
                      onTap: () async {
                        await _selectAudioTrack(null);
                        setSheetState(() {});
                        if (mounted) setState(() {});
                      },
                    ),
                    const Divider(height: 16),
                    if (_audioTracks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(VioraIcons.volumeHigh, size: 36, color: colors.textSecondary),
                              const SizedBox(height: 8),
                              Text('1 Audio Track Active', style: typography.body),
                              const SizedBox(height: 4),
                              Text(
                                'Single primary audio stream in this video.',
                                style: typography.footnote.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _audioTracks.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final track = _audioTracks[index];
                            final isSelected = !_isAutoAudio && _selectedAudioTrack?.id == track.id;

                            final details = <String>[];
                            if (track.codec.isNotEmpty && track.codec != 'Unknown') details.add(track.codec);
                            if (track.channels.isNotEmpty) details.add(track.channels);
                            if (track.bitrate > 0) details.add('${track.bitrate ~/ 1000} kbps');

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                VioraIcons.volumeHigh,
                                color: isSelected ? colors.accent : colors.textSecondary,
                                size: 20,
                              ),
                              title: Text(
                                track.language.isNotEmpty ? track.language : track.label,
                                style: typography.body.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? colors.accent : colors.textPrimary,
                                ),
                              ),
                              subtitle: details.isNotEmpty
                                  ? Text(details.join(' • '), style: typography.footnote)
                                  : null,
                              trailing: isSelected
                                  ? Icon(VioraIcons.check, color: colors.accent, size: 20)
                                  : null,
                              onTap: () async {
                                await _selectAudioTrack(track);
                                setSheetState(() {});
                                if (mounted) setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _startHideTimer();
    });
  }

  void _showSubtitlesSheet() {
    _hideControlsTimer?.cancel();
    final colors = context.colors;
    final typography = context.typography;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtitles', style: typography.headline),
                        IconButton(
                          icon: const Icon(VioraIcons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _subtitlesEnabled,
                      activeColor: colors.accent,
                      title: Text('Enable Subtitles', style: typography.body),
                      subtitle: Text(
                        _subtitlesEnabled
                            ? (_selectedSubtitleTrack?.displayTitle ?? 'Active')
                            : 'Subtitles are turned off',
                        style: typography.footnote,
                      ),
                      onChanged: (enabled) async {
                        if (!enabled) {
                          await _selectSubtitleTrack(null);
                        } else {
                          final firstTrack = _subtitleTracks.firstOrNull;
                          if (firstTrack != null) {
                            await _selectSubtitleTrack(firstTrack);
                          } else {
                            setState(() => _subtitlesEnabled = true);
                          }
                        }
                        setSheetState(() {});
                        if (mounted) setState(() {});
                      },
                    ),
                    if (_subtitlesEnabled) ...[
                      const Divider(height: 20),
                      Text(
                        'SUBTITLE TRACK',
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_subtitleTracks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No embedded subtitle tracks detected.',
                            style: typography.footnote.copyWith(color: colors.textSecondary),
                          ),
                        )
                      else
                        ..._subtitleTracks.map((track) {
                          final isSelected = _selectedSubtitleTrack?.id == track.id;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              track.isExternal ? VioraIcons.fileText : VioraIcons.subtitles,
                              color: isSelected ? colors.accent : colors.textSecondary,
                              size: 20,
                            ),
                            title: Text(
                              track.displayTitle,
                              style: typography.body.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? colors.accent : colors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              track.isExternal
                                  ? 'External file (${track.cues?.length ?? 0} cues)'
                                  : (track.mimeType.isNotEmpty ? track.mimeType : 'Embedded'),
                              style: typography.footnote,
                            ),
                            trailing: isSelected
                                ? Icon(VioraIcons.check, color: colors.accent, size: 20)
                                : null,
                            onTap: () async {
                              await _selectSubtitleTrack(track);
                              setSheetState(() {});
                              if (mounted) setState(() {});
                            },
                          );
                        }),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(VioraIcons.filePlus, color: colors.accent, size: 20),
                        ),
                        title: Text('Add External Subtitle', style: typography.body),
                        subtitle: Text('Supports .srt, .vtt, .ass, .ssa files', style: typography.footnote),
                        trailing: const Icon(VioraIcons.chevronRight, size: 18),
                        onTap: () async {
                          await _pickExternalSubtitle();
                          setSheetState(() {});
                          if (mounted) setState(() {});
                        },
                      ),
                      const Divider(height: 24),
                      Text(
                        'FONT SIZE',
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChoiceChip(
                            label: 'Small',
                            isSelected: _subtitleStyle.fontSize == 14.0,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(fontSize: 14.0));
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: 'Medium',
                            isSelected: _subtitleStyle.fontSize == 18.0,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(fontSize: 18.0));
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: 'Large',
                            isSelected: _subtitleStyle.fontSize == 22.0,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(fontSize: 22.0));
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: 'X-Large',
                            isSelected: _subtitleStyle.fontSize == 26.0,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(fontSize: 26.0));
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TEXT COLOR',
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildColorDot(Colors.white, 'White', setSheetState),
                          const SizedBox(width: 12),
                          _buildColorDot(const Color(0xFFFFEB3B), 'Yellow', setSheetState),
                          const SizedBox(width: 12),
                          _buildColorDot(const Color(0xFF00E5FF), 'Cyan', setSheetState),
                          const SizedBox(width: 12),
                          _buildColorDot(const Color(0xFF69F0AE), 'Green', setSheetState),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'BACKGROUND OPACITY',
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChoiceChip(
                            label: 'None',
                            isSelected: _subtitleStyle.backgroundColor.a == 0.0,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(
                                    backgroundColor: Colors.transparent,
                                  ));
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: 'Subtle',
                            isSelected: _subtitleStyle.backgroundColor.a > 0.0 && _subtitleStyle.backgroundColor.a < 0.5,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(
                                    backgroundColor: Colors.black.withValues(alpha: 0.35),
                                  ));
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: 'Medium',
                            isSelected: _subtitleStyle.backgroundColor.a >= 0.5 && _subtitleStyle.backgroundColor.a < 0.8,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(
                                    backgroundColor: Colors.black.withValues(alpha: 0.65),
                                  ));
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChoiceChip(
                            label: 'Solid',
                            isSelected: _subtitleStyle.backgroundColor.a >= 0.8,
                            onTap: () {
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(
                                    backgroundColor: Colors.black.withValues(alpha: 0.88),
                                  ));
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SYNC TIMING DELAY',
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              final newDelay = (_subtitleStyle.delayMs - 500).clamp(-2000, 2000);
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(delayMs: newDelay));
                              setSheetState(() {});
                            },
                            child: const Text('-0.5s'),
                          ),
                          Text(
                            '${(_subtitleStyle.delayMs / 1000).toStringAsFixed(1)}s',
                            style: typography.body.copyWith(fontWeight: FontWeight.bold),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              final newDelay = (_subtitleStyle.delayMs + 500).clamp(-2000, 2000);
                              setState(() => _subtitleStyle = _subtitleStyle.copyWith(delayMs: newDelay));
                              setSheetState(() {});
                            },
                            child: const Text('+0.5s'),
                          ),
                          TextButton(
                            onPressed: _subtitleStyle.delayMs == 0
                                ? null
                                : () {
                                    setState(() => _subtitleStyle = _subtitleStyle.copyWith(delayMs: 0));
                                    setSheetState(() {});
                                  },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _startHideTimer();
    });
  }

  void _showPlayerSettingsSheet() {
    _hideControlsTimer?.cancel();
    final colors = context.colors;
    final typography = context.typography;
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed Header with drag handle and close button
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Playback Settings', style: typography.headline),
                      IconButton(
                        icon: const Icon(VioraIcons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Scrollable Content Body (Zero overflow)
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Audio Track Tile
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(VioraIcons.volumeHigh, color: colors.accent, size: 20),
                            ),
                            title: Text('Audio Track', style: typography.body),
                            subtitle: Text(
                              _isAutoAudio
                                  ? 'Auto / Default'
                                  : (_selectedAudioTrack?.displayTitle ?? 'Default'),
                              style: typography.footnote,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_audioTracks.isNotEmpty)
                                  Text(
                                    '${_audioTracks.length} track${_audioTracks.length > 1 ? 's' : ''}',
                                    style: typography.caption.copyWith(color: colors.textSecondary),
                                  ),
                                const SizedBox(width: 4),
                                const Icon(VioraIcons.chevronRight, size: 18),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _showAudioTrackSheet();
                            },
                          ),

                          const Divider(height: 16),

                          // Subtitles Tile
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (_subtitlesEnabled ? colors.accent : colors.textSecondary).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                VioraIcons.subtitles,
                                color: _subtitlesEnabled ? colors.accent : colors.textSecondary,
                                size: 20,
                              ),
                            ),
                            title: Text('Subtitles', style: typography.body),
                            subtitle: Text(
                              _subtitlesEnabled
                                  ? (_selectedSubtitleTrack?.displayTitle ?? 'Enabled')
                                  : 'Off',
                              style: typography.footnote,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _subtitlesEnabled ? 'On' : 'Off',
                                  style: typography.caption.copyWith(
                                    color: _subtitlesEnabled ? colors.accent : colors.textSecondary,
                                    fontWeight: _subtitlesEnabled ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(VioraIcons.chevronRight, size: 18),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _showSubtitlesSheet();
                            },
                          ),

                          const Divider(height: 16),

                          // 1. Playback Speed Section
                          Text(
                            'PLAYBACK SPEED',
                            style: typography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: speeds.map((speed) {
                                final isSelected = speed == _playbackSpeed;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(speed == 1.0 ? '1.0x (Normal)' : '${speed}x'),
                                    selected: isSelected,
                                    selectedColor: colors.accent.withValues(alpha: 0.2),
                                    backgroundColor: colors.surfaceSecondary,
                                    labelStyle: TextStyle(
                                      color: isSelected ? colors.accent : colors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                    side: BorderSide(
                                      color: isSelected ? colors.accent : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _playbackSpeed = speed);
                                        _controller?.setPlaybackSpeed(speed);
                                        Navigator.pop(ctx);
                                        _startHideTimer();
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 2. Aspect Ratio Section
                          Text(
                            'ASPECT RATIO',
                            style: typography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: PlayerAspectRatio.values.map((ratio) {
                                final isSelected = ratio == _aspectRatioMode;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(ratio.label),
                                    selected: isSelected,
                                    selectedColor: colors.accent.withValues(alpha: 0.2),
                                    backgroundColor: colors.surfaceSecondary,
                                    labelStyle: TextStyle(
                                      color: isSelected ? colors.accent : colors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                    side: BorderSide(
                                      color: isSelected ? colors.accent : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _aspectRatioMode = ratio);
                                        Navigator.pop(ctx);
                                        _startHideTimer();
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 3. Picture in Picture Action Tile
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(VioraIcons.pip, color: colors.accent, size: 20),
                            ),
                            title: Text('Picture in Picture', style: typography.body),
                            subtitle: Text('Continue watching while using other apps', style: typography.footnote),
                            trailing: const Icon(VioraIcons.chevronRight, size: 18),
                            onTap: () {
                              Navigator.pop(ctx);
                              _enterPiP();
                            },
                          ),

                          const Divider(height: 24),

                          // 4. Video Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Resolution', style: typography.footnote),
                              Text(_currentVideo.resolution ?? 'Standard', style: typography.footnote.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('File Size', style: typography.footnote),
                              Text(Formatters.formatFileSize(_currentVideo.sizeBytes), style: typography.footnote),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Duration', style: typography.footnote),
                              Text(Formatters.formatDuration(_currentVideo.durationMs), style: typography.footnote),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => _startHideTimer());
  }

  Future<void> _enterPiP() async {
    final pipService = ref.read(pictureInPictureServiceProvider);
    final ratio = _controller?.value.aspectRatio ?? (16 / 9);
    await pipService.enterPictureInPicture(aspectRatio: ratio);
  }

  double _calculateBufferedMs(VideoPlayerController? controller) {
    if (controller == null || !controller.value.isInitialized) return 0.0;
    double maxBuffered = 0.0;
    for (final range in controller.value.buffered) {
      final end = range.end.inMilliseconds.toDouble();
      if (end > maxBuffered) {
        maxBuffered = end;
      }
    }
    return maxBuffered;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveCurrentPosition();
      _controller?.pause();
      _playPauseAnimController.reverse();
    }
  }

  @override
  void dispose() {
    _subtitleCueSub?.cancel();
    _tracksChangedSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _saveCurrentPosition();
    _progressSaveTimer?.cancel();
    _lockIndicatorTimer?.cancel();
    _hideControlsTimer?.cancel();
    _gestureOverlayTimer?.cancel();
    _seekAnimTimer?.cancel();
    _seekDebounceTimer?.cancel();
    _playPauseAnimController.dispose();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _exitPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _exitPlayer();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Video Renderer (viewport-aware positioning)
            Center(
              child: _buildVideoView(size),
            ),

            // 2. Gesture Capture Layer: Disambiguated single-tap and double-tap gestures
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _onVideoAreaTap,
              onDoubleTapDown: (details) {
                if (_isControlsLocked) return;
                final dx = details.globalPosition.dx;
                if (dx < size.width / 2) {
                  _seekRelative(-10);
                } else {
                  _seekRelative(10);
                }
              },
              onDoubleTap: () {}, // Required so Flutter isolates single-tap from double-tap
              onVerticalDragUpdate: (details) =>
                  _handleVerticalDragUpdate(details, size.width),
            ),

            // 3. Animated Seek Feedback Badges (-10s / +10s)
            if (_showSeekLeft)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: _buildSeekFeedback(isLeft: true),
                ),
              ),
            if (_showSeekRight)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 48),
                  child: _buildSeekFeedback(isLeft: false),
                ),
              ),

            // 4. Brightness / Volume HUD Overlay
            if (_showGestureOverlay)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: AppDimensions.borderRadiusCard,
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_gestureOverlayIcon, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _gestureOverlayText,
                        style: context.typography.headline.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Screen Lock Status Overlay (Auto-hides after ~2 seconds)
            if (_isControlsLocked)
              Positioned(
                bottom: 36,
                left: 36,
                child: AnimatedOpacity(
                  opacity: _showLockIndicator ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showLockIndicator,
                    child: GestureDetector(
                      onTap: _unlockControls,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: AppDimensions.borderRadiusPill,
                          border: Border.all(color: colors.accent, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(VioraIcons.lock, size: 18, color: colors.accent),
                            const SizedBox(width: 8),
                            Text(
                              'Tap to Unlock',
                              style: context.typography.footnote.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Live Subtitle Overlay
            if (_subtitlesEnabled && _currentSubtitleText.isNotEmpty)
              IgnorePointer(
                child: AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  left: 24,
                  right: 24,
                  bottom: (_showControls && !_isControlsLocked) ? 104.0 : 40.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _subtitleStyle.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _currentSubtitleText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _subtitleStyle.textColor,
                          fontSize: _subtitleStyle.fontSize,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Smooth Controls Overlay with Fade In / Out
            IgnorePointer(
              ignoring: !_showControls || _isControlsLocked,
              child: AnimatedOpacity(
                opacity: (_showControls && !_isControlsLocked) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _buildControlsOverlay(colors),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView(Size screenSize) {
    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(VioraIcons.alert, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: context.typography.headline.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _exitPlayer();
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    final controller = _controller!;
    final mediaQuery = MediaQuery.of(context);
    final bool isLandscapeOrientation = mediaQuery.orientation == Orientation.landscape;

    // Calculate rotation-corrected size for sizing containers accurately
    final rot = controller.value.rotationCorrection;
    final double rawWidth = controller.value.size.width;
    final double rawHeight = controller.value.size.height;
    final bool isRotated = (rot == 90 || rot == 270);
    final double effectiveWidth = isRotated ? rawHeight : rawWidth;
    final double effectiveHeight = isRotated ? rawWidth : rawHeight;
    final bool isPortraitVideo = effectiveHeight > effectiveWidth;

    // Calculate top and bottom reserved areas for portrait viewing area
    // This guarantees portrait videos appear naturally centered in the available player viewing area
    // and do NOT collide visually with the top controls or bottom playback controls
    final double topReservedHeight = (!isLandscapeOrientation && isPortraitVideo)
        ? (mediaQuery.padding.top + 54.0)
        : 0.0;
    final double bottomReservedHeight = (!isLandscapeOrientation && isPortraitVideo)
        ? (mediaQuery.padding.bottom + 76.0)
        : 0.0;

    Widget videoContent;
    switch (_aspectRatioMode) {
      case PlayerAspectRatio.fit:
        videoContent = FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: effectiveWidth > 0 ? effectiveWidth : 16,
            height: effectiveHeight > 0 ? effectiveHeight : 9,
            child: VideoPlayer(controller),
          ),
        );
        break;
      case PlayerAspectRatio.fill:
        videoContent = SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: effectiveWidth > 0 ? effectiveWidth : 16,
              height: effectiveHeight > 0 ? effectiveHeight : 9,
              child: VideoPlayer(controller),
            ),
          ),
        );
        break;
      case PlayerAspectRatio.sixteenNine:
        videoContent = AspectRatio(
          aspectRatio: 16 / 9,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: effectiveWidth > 0 ? effectiveWidth : 16,
              height: effectiveHeight > 0 ? effectiveHeight : 9,
              child: VideoPlayer(controller),
            ),
          ),
        );
        break;
      case PlayerAspectRatio.fourThree:
        videoContent = AspectRatio(
          aspectRatio: 4 / 3,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: effectiveWidth > 0 ? effectiveWidth : 16,
              height: effectiveHeight > 0 ? effectiveHeight : 9,
              child: VideoPlayer(controller),
            ),
          ),
        );
        break;
      case PlayerAspectRatio.original:
        videoContent = FittedBox(
          fit: BoxFit.none,
          child: SizedBox(
            width: effectiveWidth > 0 ? effectiveWidth : 16,
            height: effectiveHeight > 0 ? effectiveHeight : 9,
            child: VideoPlayer(controller),
          ),
        );
        break;
    }

    if (!isLandscapeOrientation && isPortraitVideo && _aspectRatioMode == PlayerAspectRatio.fit) {
      return Padding(
        padding: EdgeInsets.only(
          top: topReservedHeight,
          bottom: bottomReservedHeight,
        ),
        child: Center(child: videoContent),
      );
    }

    return Center(child: videoContent);
  }

  Widget _buildSeekFeedback({required bool isLeft}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: AppDimensions.borderRadiusCard,
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLeft ? VioraIcons.seekBackward : VioraIcons.seekForward,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 6),
          Text(
            isLeft ? '-10s' : '+10s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay(dynamic colors) {
    final controller = _controller;
    final isPlaying = controller?.value.isPlaying ?? false;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onVideoAreaTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.72),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.82),
            ],
            stops: const [0.0, 0.20, 0.76, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar (Responsive, no overflow)
              _buildTopBar(colors, isLandscape),

              // Center Playback Controls
              _buildCenterControls(colors, isPlaying),

              // Bottom Progress Bar & Time
              _buildBottomBar(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(dynamic colors, bool isLandscape) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            // Back Button
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: const Icon(VioraIcons.chevronLeft, color: Colors.white, size: 26),
              tooltip: 'Back',
              onPressed: () {
                _exitPlayer();
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 8),

            // Video Title & Resolution/Size Badges (Flexible with ellipsis)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentVideo.title,
                    style: context.typography.headline.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentVideo.resolution != null && _currentVideo.resolution!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _currentVideo.resolution!,
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        Formatters.formatFileSize(_currentVideo.sizeBytes),
                        style: context.typography.caption.copyWith(color: Colors.white70, fontSize: 11),
                      ),
                      if (_playbackSpeed != 1.0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_playbackSpeed}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Top Action Controls (Responsive layout)
            if (isLandscape) ...[
              // In Landscape: Full set of instant-access buttons
              IconButton(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                icon: const Icon(VioraIcons.aspectRatio, color: Colors.white, size: 20),
                tooltip: 'Aspect Ratio: ${_aspectRatioMode.label}',
                onPressed: _cycleAspectRatio,
              ),
              const SizedBox(width: 4),
              IconButton(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                icon: const Icon(VioraIcons.pip, color: Colors.white, size: 20),
                tooltip: 'Picture-in-Picture',
                onPressed: _enterPiP,
              ),
              const SizedBox(width: 4),
            ],

            // Screen Lock Button (Always easily accessible)
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: const Icon(VioraIcons.unlock, color: Colors.white, size: 20),
              tooltip: 'Lock Screen',
              onPressed: _lockControls,
            ),
            const SizedBox(width: 4),

            // Orientation Control Toggle
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: const Icon(
                VioraIcons.orientation,
                color: Colors.white,
                size: 20,
              ),
              tooltip: isLandscape ? 'Switch to Portrait' : 'Switch to Landscape',
              onPressed: _toggleManualOrientation,
            ),
            const SizedBox(width: 4),

            // Subtitle Quick Button
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: Icon(
                VioraIcons.subtitles,
                color: _subtitlesEnabled ? colors.accent : Colors.white,
                size: 20,
              ),
              tooltip: _subtitlesEnabled ? 'Subtitles On' : 'Subtitles Off',
              onPressed: _showSubtitlesSheet,
            ),
            const SizedBox(width: 4),

            // More Options / Playback Settings Button (Opens iOS-style settings sheet)
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: const Icon(VioraIcons.settings, color: Colors.white, size: 20),
              tooltip: 'Playback Settings',
              onPressed: _showPlayerSettingsSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls(dynamic colors, bool isPlaying) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Track in Playlist
          if (widget.playlist != null)
            IconButton(
              iconSize: 34,
              icon: Icon(
                VioraIcons.previous,
                color: _currentIndex > 0 ? Colors.white : Colors.white24,
              ),
              onPressed: _currentIndex > 0
                  ? () {
                      _playPrevious();
                      _startHideTimer();
                    }
                  : null,
            ),
          const SizedBox(width: 14),

          // Rewind 10s
          IconButton(
            iconSize: 32,
            icon: const Icon(VioraIcons.seekBackward, color: Colors.white),
            tooltip: 'Rewind 10 seconds',
            onPressed: () => _seekRelative(-10),
          ),
          const SizedBox(width: 20),

          // Central Play/Pause with animated morph
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _playPauseAnimController,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Forward 10s
          IconButton(
            iconSize: 32,
            icon: const Icon(VioraIcons.seekForward, color: Colors.white),
            tooltip: 'Forward 10 seconds',
            onPressed: () => _seekRelative(10),
          ),
          const SizedBox(width: 14),

          // Next Track in Playlist
          if (widget.playlist != null)
            IconButton(
              iconSize: 34,
              icon: Icon(
                VioraIcons.next,
                color: _currentIndex < widget.playlist!.length - 1
                    ? Colors.white
                    : Colors.white24,
              ),
              onPressed: _currentIndex < widget.playlist!.length - 1
                  ? () {
                      _playNext();
                      _startHideTimer();
                    }
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(dynamic colors) {
    final controller = _controller;
    final totalDuration = controller?.value.duration ?? Duration.zero;
    final currentPos = controller?.value.position ?? Duration.zero;

    final double maxMs = totalDuration.inMilliseconds.toDouble();
    final double bufferedMs = _calculateBufferedMs(controller).clamp(0.0, maxMs > 0 ? maxMs : 1.0);
    final double curPosMs = currentPos.inMilliseconds.toDouble().clamp(0.0, maxMs > 0 ? maxMs : 1.0);

    // If user is dragging the seekbar, prioritize drag position for instant visual feedback
    final double sliderValue = _isDraggingSeekbar
        ? _dragPositionMs.clamp(0.0, maxMs > 0 ? maxMs : 1.0)
        : curPosMs;

    final int displayCurrentMs = _isDraggingSeekbar
        ? _dragPositionMs.toInt()
        : currentPos.inMilliseconds;

    final int remainingMs = (totalDuration.inMilliseconds - displayCurrentMs).clamp(0, totalDuration.inMilliseconds);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // Absorb taps so bottom bar touches don't close controls
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fully Interactive Seekbar with Buffered Progress
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbColor: colors.accent,
                activeTrackColor: colors.accent,
                secondaryActiveTrackColor: Colors.white.withValues(alpha: 0.35),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                trackHeight: 3.5,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7.0,
                  elevation: 2.0,
                  pressedElevation: 6.0,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                overlayColor: colors.accent.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: sliderValue,
                secondaryTrackValue: bufferedMs > sliderValue ? bufferedMs : null,
                min: 0.0,
                max: maxMs > 0 ? maxMs : 1.0,
                onChangeStart: (val) {
                  _hideControlsTimer?.cancel();
                  setState(() {
                    _isDraggingSeekbar = true;
                    _dragPositionMs = val;
                  });
                },
                onChanged: (val) {
                  setState(() {
                    _dragPositionMs = val;
                  });

                  // Throttled seeking while dragging so ExoPlayer thread stays responsive
                  _seekDebounceTimer?.cancel();
                  _seekDebounceTimer = Timer(const Duration(milliseconds: 100), () {
                    if (_isDraggingSeekbar && _controller != null) {
                      _controller!.seekTo(Duration(milliseconds: val.toInt()));
                    }
                  });
                },
                onChangeEnd: (val) {
                  _seekDebounceTimer?.cancel();
                  _controller?.seekTo(Duration(milliseconds: val.toInt())).then((_) {
                    if (mounted) {
                      setState(() {
                        _isDraggingSeekbar = false;
                      });
                      _startHideTimer();
                    }
                  });
                },
              ),
            ),

            // Timestamps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.formatDuration(displayCurrentMs),
                    style: context.typography.footnote.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '-${Formatters.formatDuration(remainingMs)}',
                    style: context.typography.footnote.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
