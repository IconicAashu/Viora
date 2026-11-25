import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

enum UpiLaunchResult {
  success,
  noUpiAppFound,
  failed,
}

/// Service managing optional developer donations via UPI and external links.
class UpiDonationService {
  static const MethodChannel _channel = MethodChannel('com.viora.viora/upi');

  /// Generates the standard UPI URI format:
  /// `upi://pay?pa=iconic-aashu@ybl&pn=VIORA%20Developer&cu=INR&tn=Support%20VIORA[&am=XX.XX]`
  static String generateUpiUri({
    String upiId = AppConstants.developerUpiId,
    String name = AppConstants.developerUpiName,
    String note = AppConstants.upiTransactionNote,
    String currency = AppConstants.upiCurrency,
    double? amount,
  }) {
    final params = <String, String>{
      'pa': upiId,
      'pn': name,
      'cu': currency,
      'tn': note,
    };

    if (amount != null && amount > 0) {
      params['am'] = amount.toStringAsFixed(2);
    }

    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'upi://pay?$query';
  }

  /// Checks if any UPI application is installed and can handle `upi://pay`
  Future<bool> isUpiAvailable() async {
    try {
      final available = await _channel.invokeMethod<bool>('checkUpiAvailable');
      return available ?? false;
    } catch (_) {
      try {
        final uri = Uri.parse('upi://pay');
        return await canLaunchUrl(uri);
      } catch (_) {
        return false;
      }
    }
  }

  /// Launches installed UPI applications (Google Pay, PhonePe, Paytm, BHIM, Cred, etc.)
  Future<UpiLaunchResult> launchUpi(String upiUri) async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('launchUpi', {
        'uri': upiUri,
      });
      final launched = res?['launched'] as bool? ?? false;
      final reason = res?['reason'] as String?;

      if (launched) {
        return UpiLaunchResult.success;
      } else if (reason == 'NO_UPI_APP') {
        return UpiLaunchResult.noUpiAppFound;
      }
      return UpiLaunchResult.failed;
    } catch (e) {
      debugPrint('[UpiDonationService] Native channel failed, trying url_launcher fallback: $e');
      try {
        final uri = Uri.parse(upiUri);
        final canLaunch = await canLaunchUrl(uri);
        if (!canLaunch) {
          return UpiLaunchResult.noUpiAppFound;
        }
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        return launched ? UpiLaunchResult.success : UpiLaunchResult.failed;
      } catch (err) {
        debugPrint('[UpiDonationService] Fallback launch error: $err');
        return UpiLaunchResult.failed;
      }
    }
  }

  /// Opens an external URL in the system browser
  Future<bool> openExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('[UpiDonationService] Failed to open external URL: $e');
      return false;
    }
  }
}

final upiDonationServiceProvider = Provider<UpiDonationService>((ref) {
  return UpiDonationService();
});
