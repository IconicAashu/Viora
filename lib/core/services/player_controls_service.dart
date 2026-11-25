import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class PlayerControlsService {
  Future<void> setBrightness(double level);
  Future<double> getBrightness();
  Future<void> setVolume(double level);
  Future<double> getVolume();
}

class AndroidPlayerControlsService implements PlayerControlsService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/player_controls');

  @override
  Future<void> setBrightness(double level) async {
    try {
      await _channel.invokeMethod('setBrightness', {'level': level});
    } catch (_) {}
  }

  @override
  Future<double> getBrightness() async {
    try {
      final double? b = await _channel.invokeMethod<double>('getBrightness');
      return b ?? 0.5;
    } catch (_) {
      return 0.5;
    }
  }

  @override
  Future<void> setVolume(double level) async {
    try {
      await _channel.invokeMethod('setVolume', {'level': level});
    } catch (_) {}
  }

  @override
  Future<double> getVolume() async {
    try {
      final double? v = await _channel.invokeMethod<double>('getVolume');
      return v ?? 0.5;
    } catch (_) {
      return 0.5;
    }
  }
}

final playerControlsServiceProvider = Provider<PlayerControlsService>((ref) {
  return AndroidPlayerControlsService();
});
