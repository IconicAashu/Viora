import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlaybackState {
  idle,
  buffering,
  ready,
  ended,
  error,
}

/// Abstract contract for native video playback (Android Media3 / ExoPlayer).
abstract interface class NativePlayerBridge {
  Future<void> prepare(String filePath);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(int positionMs);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> release();

  Stream<PlaybackState> get stateStream;
  Stream<int> get positionStream;
}

/// Android Media3 native bridge implementation.
class AndroidMedia3PlayerBridge implements NativePlayerBridge {
  static const MethodChannel _methodChannel = MethodChannel('com.viora.viora/player');
  static const EventChannel _eventChannel = EventChannel('com.viora.viora/player_events');

  final StreamController<PlaybackState> _stateController = StreamController<PlaybackState>.broadcast();
  final StreamController<int> _positionController = StreamController<int>.broadcast();

  AndroidMedia3PlayerBridge() {
    _initEvents();
  }

  void _initEvents() {
    _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          final type = event['type'];
          if (type == 'state') {
            final stateIndex = event['state'] as int?;
            if (stateIndex != null && stateIndex >= 0 && stateIndex < PlaybackState.values.length) {
              _stateController.add(PlaybackState.values[stateIndex]);
            }
          } else if (type == 'position') {
            final pos = (event['position'] as num?)?.toInt();
            if (pos != null) _positionController.add(pos);
          }
        }
      },
      onError: (_) {
        _stateController.add(PlaybackState.error);
      },
    );
  }

  @override
  Future<void> prepare(String filePath) async {
    try {
      await _methodChannel.invokeMethod('prepare', {'filePath': filePath});
    } on MissingPluginException {
      // Prepared for future phase implementation
    }
  }

  @override
  Future<void> play() async {
    try {
      await _methodChannel.invokeMethod('play');
    } catch (_) {}
  }

  @override
  Future<void> pause() async {
    try {
      await _methodChannel.invokeMethod('pause');
    } catch (_) {}
  }

  @override
  Future<void> seekTo(int positionMs) async {
    try {
      await _methodChannel.invokeMethod('seekTo', {'positionMs': positionMs});
    } catch (_) {}
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _methodChannel.invokeMethod('setPlaybackSpeed', {'speed': speed});
    } catch (_) {}
  }

  @override
  Future<void> release() async {
    try {
      await _methodChannel.invokeMethod('release');
    } catch (_) {}
  }

  @override
  Stream<PlaybackState> get stateStream => _stateController.stream;

  @override
  Stream<int> get positionStream => _positionController.stream;
}

final nativePlayerBridgeProvider = Provider<NativePlayerBridge>((ref) {
  final bridge = AndroidMedia3PlayerBridge();
  ref.onDispose(bridge.release);
  return bridge;
});
