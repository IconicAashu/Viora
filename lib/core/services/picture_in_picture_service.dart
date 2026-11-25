import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class PictureInPictureService {
  Future<bool> isPictureInPictureSupported();
  Future<bool> enterPictureInPicture({double aspectRatio = 16 / 9});
}

class AndroidPictureInPictureService implements PictureInPictureService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/pip');

  @override
  Future<bool> isPictureInPictureSupported() async {
    try {
      final bool? supported = await _channel.invokeMethod<bool>('isSupported');
      return supported ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> enterPictureInPicture({double aspectRatio = 16 / 9}) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('enterPip', {
        'aspectRatio': aspectRatio,
      });
      return success ?? false;
    } catch (_) {
      return false;
    }
  }
}

final pictureInPictureServiceProvider = Provider<PictureInPictureService>((ref) {
  return AndroidPictureInPictureService();
});
