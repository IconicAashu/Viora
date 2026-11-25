import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../utilities/formatters.dart';

/// Structured metadata describing a published application release from GitHub Releases.
class AppReleaseInfo {
  const AppReleaseInfo({
    required this.version,
    required this.versionCode,
    required this.title,
    required this.releaseNotes,
    required this.releaseDate,
    this.apkFileName,
    this.apkDownloadUrl,
    this.apkSizeBytes,
    this.sha256Checksum,
    this.sha256AssetUrl,
    this.htmlUrl,
    this.isPrerelease = false,
  });

  final String version;
  final int versionCode;
  final String title;
  final String releaseNotes;
  final String releaseDate;
  final String? apkFileName;
  final String? apkDownloadUrl;
  final int? apkSizeBytes;
  final String? sha256Checksum;
  final String? sha256AssetUrl;
  final String? htmlUrl;
  final bool isPrerelease;

  /// Parses a GitHub Release API response object.
  factory AppReleaseInfo.fromGitHubJson(Map<String, dynamic> json) {
    // 1. Tag name -> Version (e.g. "v1.0.1" -> "1.0.1")
    final rawTag = (json['tag_name'] as String? ?? '').trim();
    final cleanVersion = rawTag.startsWith('v') || rawTag.startsWith('V')
        ? rawTag.substring(1)
        : (rawTag.isNotEmpty ? rawTag : AppConstants.appVersion);

    // 2. Title & Release Notes
    final title = (json['name'] as String?)?.trim() ?? 'VIORA $cleanVersion';
    final body = (json['body'] as String?)?.trim() ?? 'Performance improvements and bug fixes.';

    // 3. Published date
    final rawPublishedAt = json['published_at'] as String?;
    String formattedDate = 'Recent';
    if (rawPublishedAt != null) {
      try {
        final parsedDate = DateTime.parse(rawPublishedAt);
        formattedDate = Formatters.formatDate(parsedDate);
      } catch (_) {
        formattedDate = rawPublishedAt;
      }
    }

    // 4. Select official Android APK asset from assets[]
    final rawAssets = json['assets'] as List<dynamic>? ?? [];
    Map<String, dynamic>? selectedApkAsset;
    String? sha256AssetUrl;

    for (final item in rawAssets) {
      if (item is Map<String, dynamic>) {
        final name = (item['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          // Prefer asset matching 'viora' or 'release' if multiple APKs exist
          if (selectedApkAsset == null || name.contains('viora') || name.contains('release')) {
            selectedApkAsset = item;
          }
        } else if (name.endsWith('.sha256') || name.contains('checksum')) {
          sha256AssetUrl = item['browser_download_url'] as String?;
        }
      }
    }

    // 5. Look for SHA-256 hash in release body
    String? extractedChecksum;
    final shaRegex = RegExp(r'(?:sha-?256|sha256sum|checksum)[:\s]+([a-fA-F0-9]{64})', caseSensitive: false);
    final match = shaRegex.firstMatch(body);
    if (match != null) {
      extractedChecksum = match.group(1);
    }

    // 6. Estimate versionCode from semver (major * 10000 + minor * 100 + patch)
    int parsedCode = 1;
    final parts = cleanVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    if (parts.length >= 3) {
      parsedCode = parts[0] * 10000 + parts[1] * 100 + parts[2];
    }

    return AppReleaseInfo(
      version: cleanVersion,
      versionCode: parsedCode,
      title: title,
      releaseNotes: body,
      releaseDate: formattedDate,
      apkFileName: selectedApkAsset?['name'] as String?,
      apkDownloadUrl: selectedApkAsset?['browser_download_url'] as String?,
      apkSizeBytes: selectedApkAsset?['size'] as int?,
      sha256Checksum: extractedChecksum,
      sha256AssetUrl: sha256AssetUrl,
      htmlUrl: json['html_url'] as String?,
      isPrerelease: json['prerelease'] as bool? ?? false,
    );
  }
}

enum UpdateStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  noReleases,
  noApkAsset,
  notConfigured,
  offline,
  rateLimited,
  error,
  downloading,
  verifying,
  readyToInstall,
}

class UpdateState {
  const UpdateState({
    this.status = UpdateStatus.idle,
    this.releaseInfo,
    this.errorMessage,
    this.downloadProgress = 0.0,
    this.downloadedFilePath,
    this.lastChecked,
  });

  final UpdateStatus status;
  final AppReleaseInfo? releaseInfo;
  final String? errorMessage;
  final double downloadProgress;
  final String? downloadedFilePath;
  final DateTime? lastChecked;

  UpdateState copyWith({
    UpdateStatus? status,
    AppReleaseInfo? releaseInfo,
    String? errorMessage,
    double? downloadProgress,
    String? downloadedFilePath,
    DateTime? lastChecked,
  }) {
    return UpdateState(
      status: status ?? this.status,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      errorMessage: errorMessage,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class UpdateService extends Notifier<UpdateState> {
  @override
  UpdateState build() {
    return const UpdateState();
  }

  static const _channel = MethodChannel('com.viora.viora/app_update');
  HttpClientRequest? _currentDownloadRequest;

  /// Compares semantic versions (e.g. "1.1.0" > "1.0.0").
  /// Returns 1 if v1 > v2, -1 if v1 < v2, and 0 if equal.
  static int compareVersions(String v1, String v2) {
    try {
      final cleanV1 = v1.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanV2 = v2.split('+').first.replaceAll(RegExp(r'[^0-9.]'), '');

      final parts1 = cleanV1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final parts2 = cleanV2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
      for (int i = 0; i < maxLen; i++) {
        final p1 = i < parts1.length ? parts1[i] : 0;
        final p2 = i < parts2.length ? parts2[i] : 0;
        if (p1 > p2) return 1;
        if (p1 < p2) return -1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Checks the official GitHub Releases API for published releases.
  Future<void> checkForUpdates() async {
    const endpoint = AppConstants.updateMetadataUrl;

    state = state.copyWith(status: UpdateStatus.checking, errorMessage: null);

    // Attempt request with 1 automatic retry on recoverable network hiccups
    for (int attempt = 1; attempt <= 2; attempt++) {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);

      try {
        final uri = Uri.parse(endpoint);
        final request = await client.getUrl(uri);
        request.headers.add('Accept', 'application/vnd.github.v3+json');
        request.headers.add('User-Agent', 'VIORA/${AppConstants.appVersion}');

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode == 200) {
          final jsonMap = jsonDecode(responseBody) as Map<String, dynamic>;
          final release = AppReleaseInfo.fromGitHubJson(jsonMap);

          // Check if release has an official Android APK asset attached
          if (release.apkDownloadUrl == null) {
            state = state.copyWith(
              status: UpdateStatus.noApkAsset,
              releaseInfo: release,
              lastChecked: DateTime.now(),
              errorMessage: 'Release ${release.version} was found, but no Android APK asset is attached yet.',
            );
            return;
          }

          final versionDiff = compareVersions(release.version, AppConstants.appVersion);
          final isVersionNewer = versionDiff > 0 ||
              (versionDiff == 0 && release.versionCode > AppConstants.appBuildNumber);

          if (isVersionNewer) {
            state = state.copyWith(
              status: UpdateStatus.updateAvailable,
              releaseInfo: release,
              lastChecked: DateTime.now(),
            );
          } else {
            state = state.copyWith(
              status: UpdateStatus.upToDate,
              releaseInfo: release,
              lastChecked: DateTime.now(),
            );
          }
          return;
        } else if (response.statusCode == 404) {
          // GitHub returns 404 when no releases have been published to the repository yet
          state = state.copyWith(
            status: UpdateStatus.noReleases,
            lastChecked: DateTime.now(),
            errorMessage: 'No published releases found on GitHub. You are running the initial version (${AppConstants.appVersion}).',
          );
          return;
        } else if (response.statusCode == 403 && responseBody.toLowerCase().contains('rate limit')) {
          state = state.copyWith(
            status: UpdateStatus.rateLimited,
            lastChecked: DateTime.now(),
            errorMessage: 'GitHub API rate limit exceeded. Please try again later.',
          );
          return;
        } else {
          state = state.copyWith(
            status: UpdateStatus.error,
            errorMessage: 'GitHub API responded with status ${response.statusCode}.',
            lastChecked: DateTime.now(),
          );
          return;
        }
      } on SocketException {
        if (attempt == 1) {
          await Future.delayed(const Duration(milliseconds: 600));
          continue; // Retry once
        }
        state = state.copyWith(
          status: UpdateStatus.offline,
          errorMessage: 'Network unavailable. VIORA operates offline; connect to the internet to check for releases.',
          lastChecked: DateTime.now(),
        );
        return;
      } on TimeoutException {
        if (attempt == 1) {
          await Future.delayed(const Duration(milliseconds: 600));
          continue; // Retry once
        }
        state = state.copyWith(
          status: UpdateStatus.offline,
          errorMessage: 'Connection timed out while querying GitHub Releases.',
          lastChecked: DateTime.now(),
        );
        return;
      } catch (e) {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: 'Update check failed: $e',
          lastChecked: DateTime.now(),
        );
        return;
      } finally {
        client.close();
      }
    }
  }

  /// Downloads the APK securely from GitHub over HTTPS, tracking progress and validating SHA-256.
  Future<void> downloadAndInstallUpdate() async {
    final release = state.releaseInfo;
    final downloadUrl = release?.apkDownloadUrl;

    if (downloadUrl == null || !downloadUrl.startsWith('https://')) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Direct APK download link is not available or insecure.',
      );
      return;
    }

    state = state.copyWith(status: UpdateStatus.downloading, downloadProgress: 0.0);

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final tempDir = await getTemporaryDirectory();
      final targetFile = File('${tempDir.path}/viora_update_${release!.version}.apk');
      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      final request = await client.getUrl(Uri.parse(downloadUrl));
      request.headers.add('User-Agent', 'VIORA/${AppConstants.appVersion}');
      _currentDownloadRequest = request;

      final response = await request.close();
      if (response.statusCode != 200 && response.statusCode != 302) {
        throw HttpException('Download failed with status ${response.statusCode}');
      }

      // Handle GitHub redirect if 302
      HttpClientResponse actualResponse = response;
      if (response.statusCode == 302) {
        final redirectUrl = response.headers.value('location');
        if (redirectUrl != null) {
          final redirectRequest = await client.getUrl(Uri.parse(redirectUrl));
          _currentDownloadRequest = redirectRequest;
          actualResponse = await redirectRequest.close();
        }
      }

      final contentLength = actualResponse.contentLength;
      int receivedBytes = 0;
      final sink = targetFile.openWrite();

      await for (final chunk in actualResponse) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          state = state.copyWith(
            downloadProgress: (receivedBytes / contentLength).clamp(0.0, 1.0),
          );
        }
      }

      await sink.flush();
      await sink.close();

      // Check for companion SHA-256 asset if inline checksum was not in body
      String? expectedHash = release.sha256Checksum?.trim().toLowerCase();
      if (expectedHash == null && release.sha256AssetUrl != null) {
        try {
          final shaReq = await client.getUrl(Uri.parse(release.sha256AssetUrl!));
          final shaRes = await shaReq.close();
          if (shaRes.statusCode == 200) {
            final shaBody = await shaRes.transform(utf8.decoder).join();
            final shaMatch = RegExp(r'([a-fA-F0-9]{64})').firstMatch(shaBody);
            if (shaMatch != null) {
              expectedHash = shaMatch.group(1)?.toLowerCase();
            }
          }
        } catch (_) {}
      }

      // Verify SHA-256 checksum if available
      state = state.copyWith(status: UpdateStatus.verifying);
      if (expectedHash != null && expectedHash.isNotEmpty) {
        final bytes = await targetFile.readAsBytes();
        final actualHash = sha256.convert(bytes).toString().toLowerCase();

        if (actualHash != expectedHash) {
          await targetFile.delete();
          state = state.copyWith(
            status: UpdateStatus.error,
            errorMessage: 'Security verification failed: SHA-256 checksum mismatch. Download rejected.',
          );
          return;
        }
      }

      state = state.copyWith(
        status: UpdateStatus.readyToInstall,
        downloadedFilePath: targetFile.path,
        downloadProgress: 1.0,
      );

      // Trigger official Android system package installer
      await installDownloadedApk(targetFile.path);
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Download failed: $e',
      );
    } finally {
      _currentDownloadRequest = null;
      client.close();
    }
  }

  /// Cancels any in-progress APK download.
  void cancelDownload() {
    _currentDownloadRequest?.abort();
    _currentDownloadRequest = null;
    state = state.copyWith(
      status: UpdateStatus.idle,
      downloadProgress: 0.0,
    );
  }

  /// Requests Android system installer via MethodChannel.
  Future<bool> installDownloadedApk(String filePath) async {
    try {
      final canInstall = await _channel.invokeMethod<bool>('canInstallPackages') ?? false;
      if (!canInstall) {
        await _channel.invokeMethod('openInstallPermissionSettings');
        return false;
      }
      final success = await _channel.invokeMethod<bool>('installApk', {'filePath': filePath}) ?? false;
      return success;
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Installation error: $e',
      );
      return false;
    }
  }

  /// Checks if unknown app install permission is granted.
  Future<bool> canInstallPackages() async {
    try {
      return await _channel.invokeMethod<bool>('canInstallPackages') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens system settings for unknown package installs.
  Future<void> openInstallPermissionSettings() async {
    try {
      await _channel.invokeMethod('openInstallPermissionSettings');
    } catch (_) {}
  }
}

final updateServiceProvider = NotifierProvider<UpdateService, UpdateState>(
  UpdateService.new,
);
