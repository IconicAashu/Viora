import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/update_service.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/formatters.dart';
import '../../../shared/widgets/viora_app_bar.dart';
import '../../../shared/widgets/viora_card.dart';
import '../../../shared/widgets/viora_logo.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  void _showPrivacyPolicyDialog(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Row(
            children: [
              Icon(VioraIcons.security, color: colors.accent, size: 24),
              const SizedBox(width: 10),
              Text('Privacy Manifesto', style: typography.headline),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VIORA was founded on uncompromising privacy principles:',
                  style: typography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildBulletPoint('1. Offline-First: All video scanning and playback metadata is stored in a local SQLite database on your device.', typography),
                _buildBulletPoint('2. Zero Telemetry: No analytics, tracking tokens, device fingerprints, or advertising SDKs exist in VIORA.', typography),
                _buildBulletPoint('3. No Accounts Required: VIORA does not require accounts, sign-ins, or cloud subscriptions to use any feature.', typography),
                _buildBulletPoint('4. Secure Updates: Any optional app update verification connects exclusively over HTTPS with cryptographic SHA-256 validation.', typography),
                const SizedBox(height: 12),
                Text(
                  'Your media is yours alone. Every Frame, Beautifully.',
                  style: typography.caption.copyWith(color: colors.textSecondary, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: TextStyle(color: colors.accent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBulletPoint(String text, dynamic typography) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: typography.footnote),
    );
  }

  void _showCopiedSnackbar(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final updateState = ref.watch(updateServiceProvider);
    final updateService = ref.read(updateServiceProvider.notifier);

    return Scaffold(
      appBar: const VioraAppBar(
        title: 'About VIORA',
        subtitle: AppConstants.appTagline,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Branding & Identity
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const VioraLogo(
                  size: 88,
                  showWordmark: true,
                  showTagline: true,
                  heroTag: 'about_viora_logo',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.12),
                    borderRadius: AppDimensions.borderRadiusPill,
                    border: Border.all(color: colors.accent.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    'Version ${AppConstants.appVersion} (Build ${AppConstants.appBuildNumber})',
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Section 2: About Description Card
          VioraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ABOUT', style: typography.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appDescription,
                  style: typography.body.copyWith(height: 1.45),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPillBadge(VioraIcons.offline, '100% Offline-First', colors),
                    _buildPillBadge(VioraIcons.security, 'Zero Tracking', colors),
                    _buildPillBadge(VioraIcons.sparkles, 'Ad-Free', colors),
                    _buildPillBadge(VioraIcons.hardware, 'ExoPlayer Hardware Engine', colors),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 3: App Updates & Release Management
          Text('UPDATES', style: typography.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          VioraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(VioraIcons.refresh, size: 20, color: colors.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Software Updates', style: typography.headline),
                          const SizedBox(height: 2),
                          Text(
                            updateState.lastChecked != null
                                ? 'Last checked: ${Formatters.formatDate(updateState.lastChecked!)}'
                                : 'Check for newer releases and security updates',
                            style: typography.footnote,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Update Status Display
                if (updateState.status == UpdateStatus.checking) ...[
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text('Checking for updates...', style: typography.footnote),
                    ],
                  ),
                ] else if (updateState.status == UpdateStatus.upToDate) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.12),
                      borderRadius: AppDimensions.borderRadiusCompact,
                      border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(VioraIcons.checkCircle, color: colors.success, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "You're using the latest version of VIORA.",
                            style: typography.footnote.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (updateState.status == UpdateStatus.updateAvailable) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.12),
                      borderRadius: AppDimensions.borderRadiusCompact,
                      border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(VioraIcons.sparkles, color: colors.accent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                updateState.releaseInfo?.title ?? 'Version ${updateState.releaseInfo?.version ?? ""} Available',
                                style: typography.headline.copyWith(color: colors.accent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Release Date: ${updateState.releaseInfo?.releaseDate ?? "Recent"}',
                              style: typography.caption.copyWith(color: colors.textSecondary),
                            ),
                            if (updateState.releaseInfo?.apkSizeBytes != null) ...[
                              const SizedBox(width: 10),
                              Text('•', style: TextStyle(color: colors.textSecondary)),
                              const SizedBox(width: 10),
                              Text(
                                Formatters.formatFileSize(updateState.releaseInfo!.apkSizeBytes!),
                                style: typography.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          updateState.releaseInfo?.releaseNotes ?? 'New improvements and bug fixes available.',
                          style: typography.footnote,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusButton),
                          ),
                          onPressed: () => updateService.downloadAndInstallUpdate(),
                          icon: const Icon(VioraIcons.download, size: 18),
                          label: const Text('Download & Install Update'),
                        ),
                      ],
                    ),
                  ),
                ] else if (updateState.status == UpdateStatus.noReleases) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      borderRadius: AppDimensions.borderRadiusCompact,
                      border: Border.all(color: colors.separator),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(VioraIcons.gitCommit, color: colors.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GitHub Repository Connected', style: typography.headline.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                updateState.errorMessage ?? 'No published releases found on GitHub yet. You are running the initial version (v${AppConstants.appVersion}).',
                                style: typography.footnote,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (updateState.status == UpdateStatus.noApkAsset) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.12),
                      borderRadius: AppDimensions.borderRadiusCompact,
                      border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(VioraIcons.alert, color: colors.warning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            updateState.errorMessage ?? 'Release found, but no Android APK asset is attached.',
                            style: typography.footnote,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (updateState.status == UpdateStatus.rateLimited) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.12),
                      borderRadius: AppDimensions.borderRadiusCompact,
                      border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(VioraIcons.recent, color: colors.warning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            updateState.errorMessage ?? 'GitHub API rate limit reached. Please try again later.',
                            style: typography.footnote,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (updateState.status == UpdateStatus.downloading) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Downloading update...', style: typography.footnote),
                          Text('${(updateState.downloadProgress * 100).toInt()}%', style: typography.footnote.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: updateState.downloadProgress > 0 ? updateState.downloadProgress : null,
                        color: colors.accent,
                        backgroundColor: colors.surfaceSecondary,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => updateService.cancelDownload(),
                        child: Text('Cancel', style: TextStyle(color: colors.danger)),
                      ),
                    ],
                  ),
                ] else if (updateState.status == UpdateStatus.verifying) ...[
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text('Verifying SHA-256 cryptographic signature...', style: typography.footnote),
                    ],
                  ),
                ] else if (updateState.status == UpdateStatus.offline) ...[
                  Row(
                    children: [
                      Icon(VioraIcons.offline, color: colors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          updateState.errorMessage ?? 'Network unavailable. VIORA operates offline.',
                          style: typography.footnote.copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ] else if (updateState.status == UpdateStatus.notConfigured) ...[
                  Row(
                    children: [
                      Icon(VioraIcons.info, color: colors.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Release channel is configured for offline direct builds.',
                          style: typography.footnote.copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ] else if (updateState.status == UpdateStatus.error) ...[
                  Row(
                    children: [
                      Icon(VioraIcons.alert, color: colors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          updateState.errorMessage ?? 'Unable to check for updates.',
                          style: typography.footnote.copyWith(color: colors.danger),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.accent),
                    shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusButton),
                  ),
                  onPressed: updateState.status == UpdateStatus.checking
                      ? null
                      : () => updateService.checkForUpdates(),
                  icon: const Icon(VioraIcons.refresh, size: 16),
                  label: const Text('Check for Updates'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 4: What's New / Structured Changelog
          Text("WHAT'S NEW", style: typography.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...AppConstants.changelog.map((log) {
            final version = log['version'] as String;
            final date = log['date'] as String;
            final highlights = (log['highlights'] as List).cast<String>();
            final bugFixes = (log['bugFixes'] as List).cast<String>();

            return VioraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Version $version', style: typography.headline.copyWith(fontWeight: FontWeight.bold)),
                      Text(date, style: typography.caption.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('NEW & IMPROVED', style: typography.caption.copyWith(color: colors.accent, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  ...highlights.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(item, style: typography.footnote)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 10),
                  Text('BUG FIXES & STABILITY', style: typography.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  ...bugFixes.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(item, style: typography.footnote)),
                          ],
                        ),
                      )),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Section 5: Developer Credits
          Text('DEVELOPER CREDITS', style: typography.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          VioraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.accent.withValues(alpha: 0.15),
                    child: Icon(VioraIcons.github, color: colors.accent),
                  ),
                  title: Text(AppConstants.developerName, style: typography.headline),
                  subtitle: Text(AppConstants.developerRole, style: typography.footnote),
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(VioraIcons.globe, size: 20, color: colors.textPrimary),
                  title: const Text('GitHub Profile'),
                  subtitle: Text(AppConstants.developerGitHub, style: typography.caption),
                  trailing: const Icon(VioraIcons.externalLink, size: 16),
                  onTap: () => _showCopiedSnackbar('GitHub link', AppConstants.developerGitHub),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(VioraIcons.gitBranch, size: 20, color: colors.textPrimary),
                  title: const Text('GitHub Repository'),
                  subtitle: Text(AppConstants.gitHubRepositoryUrl, style: typography.caption),
                  trailing: const Icon(VioraIcons.externalLink, size: 16),
                  onTap: () => _showCopiedSnackbar('Repository link', AppConstants.gitHubRepositoryUrl),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(VioraIcons.mail, size: 20, color: colors.textPrimary),
                  title: const Text('Contact Email'),
                  subtitle: Text(AppConstants.developerEmail, style: typography.caption),
                  trailing: const Icon(VioraIcons.copy, size: 16),
                  onTap: () => _showCopiedSnackbar('Email address', AppConstants.developerEmail),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 6: Legal & Open Source
          Text('LEGAL & LICENSES', style: typography.caption.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          VioraCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(VioraIcons.security, color: colors.accent, size: 20),
                  title: Text('Privacy Policy & Manifesto', style: typography.headline),
                  subtitle: Text('Review our 100% offline-first privacy standards', style: typography.footnote),
                  trailing: const Icon(VioraIcons.chevronRight, size: 18),
                  onTap: () => _showPrivacyPolicyDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(VioraIcons.fileText, color: colors.accent, size: 20),
                  title: Text('Open Source Licenses', style: typography.headline),
                  subtitle: Text('Third-party software libraries and notices', style: typography.footnote),
                  trailing: const Icon(VioraIcons.chevronRight, size: 18),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: 'v${AppConstants.appVersion}',
                      applicationIcon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: VioraLogo(size: 48),
                      ),
                      applicationLegalese: 'Copyright © 2026 ${AppConstants.developerName}. All rights reserved.',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildPillBadge(IconData icon, String text, dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppDimensions.borderRadiusPill,
        border: Border.all(color: colors.separator, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.accent),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
