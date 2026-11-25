import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MediaPermissionStatus {
  notDetermined,
  granted,
  denied,
  permanentlyDenied,
  restricted;

  bool get isGranted => this == MediaPermissionStatus.granted;
}

/// Abstract contract for media permission handling.
/// Encapsulates platform-specific checks (e.g. READ_MEDIA_VIDEO on Android 13+,
/// READ_EXTERNAL_STORAGE on legacy Android, or Photos on iOS).
abstract interface class MediaPermissionService {
  Future<MediaPermissionStatus> checkVideoPermission();
  Future<MediaPermissionStatus> requestVideoPermission();
  Future<bool> hasVideoPermission();
  Future<bool> openAppSettings();
}

/// Android platform implementation using clean MethodChannel communication.
class AndroidMediaPermissionService implements MediaPermissionService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/permissions');

  @override
  Future<MediaPermissionStatus> checkVideoPermission() async {
    try {
      final int? statusIndex = await _channel.invokeMethod<int>('checkVideoPermission');
      return _parseStatus(statusIndex);
    } on PlatformException {
      return MediaPermissionStatus.notDetermined;
    } on MissingPluginException {
      // Safe fallback before native side is connected
      return MediaPermissionStatus.notDetermined;
    }
  }

  @override
  Future<MediaPermissionStatus> requestVideoPermission() async {
    try {
      final int? statusIndex = await _channel.invokeMethod<int>('requestVideoPermission');
      return _parseStatus(statusIndex);
    } on PlatformException {
      return MediaPermissionStatus.denied;
    } on MissingPluginException {
      return MediaPermissionStatus.denied;
    }
  }

  @override
  Future<bool> hasVideoPermission() async {
    final status = await checkVideoPermission();
    return status.isGranted;
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('openAppSettings');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  MediaPermissionStatus _parseStatus(int? index) {
    if (index == null || index < 0 || index >= MediaPermissionStatus.values.length) {
      return MediaPermissionStatus.notDetermined;
    }
    return MediaPermissionStatus.values[index];
  }
}

/// Riverpod provider for media permission service.
final mediaPermissionServiceProvider = Provider<MediaPermissionService>((ref) {
  return AndroidMediaPermissionService();
});
