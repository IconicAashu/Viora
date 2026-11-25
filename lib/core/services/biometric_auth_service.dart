import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class BiometricAuthService {
  Future<bool> canAuthenticate();
  Future<bool> authenticate({String title, String subtitle});
}

class AndroidBiometricAuthService implements BiometricAuthService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/biometrics');

  @override
  Future<bool> canAuthenticate() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('canAuthenticate');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({
    String title = 'Unlock VIORA',
    String subtitle = 'Confirm your fingerprint, face, or device PIN',
  }) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('authenticate', {
        'title': title,
        'subtitle': subtitle,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return AndroidBiometricAuthService();
});
