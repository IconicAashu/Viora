import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class AndroidSecureStorageService implements SecureStorageService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/secure_storage');

  @override
  Future<void> write(String key, String value) async {
    try {
      await _channel.invokeMethod('write', {'key': key, 'value': value});
    } catch (_) {}
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _channel.invokeMethod<String>('read', {'key': key});
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _channel.invokeMethod('delete', {'key': key});
    } catch (_) {}
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _channel.invokeMethod('deleteAll');
    } catch (_) {}
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return AndroidSecureStorageService();
});
