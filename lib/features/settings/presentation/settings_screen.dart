import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/database.dart';
import '../../../core/permissions/media_permission_service.dart';
import '../../../core/services/video_discovery_service.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/viora_icons.dart';
import '../../../core/utilities/viora_page_route.dart';
import '../../../shared/widgets/viora_app_bar.dart';
import '../../../shared/widgets/viora_card.dart';
import '../../backup/services/backup_service.dart';
import '../../privacy/presentation/vault_screen.dart';
import 'about_screen.dart';
import 'support_viora_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isRescanning = false;
  int _minDurationSeconds = 1;

  @override
  void initState() {
    super.initState();
    _loadMinDurationPreference();
  }

  Future<void> _loadMinDurationPreference() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final pref = await (db.select(db.userPreferences)..where((tbl) => tbl.key.equals('min_duration_seconds'))).getSingleOrNull();
      if (pref != null) {
        final val = int.tryParse(pref.value);
        if (val != null && mounted) {
          setState(() => _minDurationSeconds = val);
        }
      }
    } catch (_) {}
  }

  Future<void> _setMinDurationPreference(int seconds) async {
    setState(() => _minDurationSeconds = seconds);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.into(db.userPreferences).insertOnConflictUpdate(
            UserPreferencesCompanion.insert(
              key: 'min_duration_seconds',
              value: seconds.toString(),
              updatedAt: DateTime.now(),
            ),
          );
    } catch (_) {}
  }

  Future<void> _rescanLibrary() async {
    if (_isRescanning) return;
    setState(() => _isRescanning = true);

    try {
      final permService = ref.read(mediaPermissionServiceProvider);
      final status = await permService.requestVideoPermission();
      if (status.isGranted) {
        final discovery = ref.read(videoDiscoveryServiceProvider);
        final db = ref.read(appDatabaseProvider);
        final count = await discovery.syncWithDatabase(db, minDurationMs: _minDurationSeconds * 1000);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Library scan completed: $count videos synced')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required to scan videos')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRescanning = false);
      }
    }
  }

  Future<void> _handleExportBackup() async {
    final db = ref.read(appDatabaseProvider);
    final backupService = ref.read(backupServiceProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await backupService.exportBackup(db);
    if (mounted) {
      Navigator.pop(context); // close spinner
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: context.colors.surface,
            shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
            title: Text(result.success ? 'Backup Created' : 'Backup Failed', style: context.typography.title3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.message ?? '', style: context.typography.body),
                const SizedBox(height: AppDimensions.space12),
                Text(
                  'Notice: Backups contain your playlists, favorites, and settings. Original video files remain exclusively on your device.',
                  style: context.typography.caption.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Done', style: TextStyle(color: context.colors.accent)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _handleRestoreBackup() async {
    final backupService = ref.read(backupServiceProvider);
    final files = await backupService.listBackups();

    if (!mounted) return;

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No local VIORA backup files found in app storage.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Restore Backup', style: context.typography.title3),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: files.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (c, idx) {
                final file = files[idx];
                final fileName = file.path.split(Platform.pathSeparator).last;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(VioraIcons.backup, color: context.colors.accent),
                  title: Text(fileName, style: context.typography.subheadline),
                  subtitle: Text(
                    'Modified ${file.statSync().modified.toLocal().toString().split('.').first}',
                    style: context.typography.caption,
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _confirmRestoreFile(file);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  void _confirmRestoreFile(File file) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
          title: Text('Confirm Restore', style: context.typography.title3),
          content: Text(
            'Restoring this backup will merge playlists, favorites, and preferences into your local library.',
            style: context.typography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final db = ref.read(appDatabaseProvider);
                final backupService = ref.read(backupServiceProvider);
                final result = await backupService.restoreBackup(db, file.path);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.message ?? 'Restore completed')),
                  );
                }
              },
              child: Text('Restore', style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentAccent = ref.watch(accentPresetProvider);
    final reduceMotionOverride = ref.watch(reduceMotionOverrideProvider);

    return Scaffold(
      appBar: const VioraAppBar(
        title: 'Settings',
        isLargeTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
        children: [
          // Appearance Section
          Text('Appearance', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Theme Mode Selector
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Row(
                    children: [
                      Icon(VioraIcons.theme, color: colors.accent, size: AppDimensions.iconMedium),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Text('Theme Mode', style: typography.headline),
                      ),
                      DropdownButton<ThemeMode>(
                        value: currentThemeMode,
                        underline: const SizedBox.shrink(),
                        dropdownColor: colors.surface,
                        borderRadius: AppDimensions.borderRadiusCompact,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System (Default)'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark (OLED)'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            ref.read(themeModeProvider.notifier).setThemeMode(mode);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.separator),

                // Accent Color Selector
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(VioraIcons.palette, color: colors.accent, size: AppDimensions.iconMedium),
                          const SizedBox(width: AppDimensions.space12),
                          Text('Accent Color', style: typography.headline),
                          const Spacer(),
                          Text(currentAccent.label, style: typography.footnote),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: AccentPreset.values.map((preset) {
                          final isSelected = preset == currentAccent;
                          return GestureDetector(
                            onTap: () {
                              ref.read(accentPresetProvider.notifier).setPreset(preset);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: preset.accentFor(context.brightness),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 3.0)
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: preset.accentFor(context.brightness).withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(VioraIcons.check, size: 20, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Library & Discovery Section
          Text('Video Discovery', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Row(
                    children: [
                      Icon(VioraIcons.filter, color: colors.accent, size: AppDimensions.iconMedium),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Minimum Duration', style: typography.headline),
                            const SizedBox(height: 2),
                            Text('Filter out short clips and sound bites', style: typography.footnote),
                          ],
                        ),
                      ),
                      DropdownButton<int>(
                        value: _minDurationSeconds,
                        underline: const SizedBox.shrink(),
                        dropdownColor: colors.surface,
                        borderRadius: AppDimensions.borderRadiusCompact,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('All videos')),
                          DropdownMenuItem(value: 5, child: Text('> 5s')),
                          DropdownMenuItem(value: 30, child: Text('> 30s')),
                          DropdownMenuItem(value: 60, child: Text('> 60s')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _setMinDurationPreference(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.separator),
                ListTile(
                  leading: Icon(VioraIcons.refresh, color: colors.accent, size: AppDimensions.iconMedium),
                  title: Text('Rescan Storage', style: typography.headline),
                  subtitle: Text('Force refresh video index from device storage', style: typography.footnote),
                  trailing: _isRescanning
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent),
                        )
                      : Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: 20),
                  onTap: _rescanLibrary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Security & Vault Section
          Text('Security & Vault', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(VioraIcons.lock, color: colors.warning, size: AppDimensions.iconMedium),
                  title: Text('Private Vault', style: typography.headline),
                  subtitle: Text('Manage biometric-protected hidden videos', style: typography.footnote),
                  trailing: Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: 20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VaultScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Backup & Restore Section
          Text('Backup & Restore', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(VioraIcons.backup, color: colors.accent, size: AppDimensions.iconMedium),
                  title: Text('Export Metadata Backup', style: typography.headline),
                  subtitle: Text('Export playlists, favorites, and settings as JSON', style: typography.footnote),
                  trailing: Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: 20),
                  onTap: _handleExportBackup,
                ),
                Divider(height: 1, color: colors.separator),
                ListTile(
                  leading: Icon(VioraIcons.restore, color: colors.accent, size: AppDimensions.iconMedium),
                  title: Text('Restore from Backup', style: typography.headline),
                  subtitle: Text('Merge playlists and settings from local backup file', style: typography.footnote),
                  trailing: Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: 20),
                  onTap: _handleRestoreBackup,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Accessibility Section
          Text('Accessibility', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            child: Row(
              children: [
                Icon(VioraIcons.sparkles, color: colors.accent, size: AppDimensions.iconMedium),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reduce Motion', style: typography.headline),
                      const SizedBox(height: 2),
                      Text('Minimizes UI animations and transitions', style: typography.footnote),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: reduceMotionOverride ?? false,
                  activeTrackColor: colors.accent,
                  onChanged: (val) {
                    ref.read(reduceMotionOverrideProvider.notifier).setOverride(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Privacy & Security Manifesto
          Text('Privacy Guarantee', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            child: Column(
              children: [
                _buildInfoRow(
                  icon: VioraIcons.offline,
                  title: '100% Offline-First',
                  subtitle: 'No video files or telemetry ever leave your device.',
                  colors: colors,
                  typography: typography,
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildInfoRow(
                  icon: VioraIcons.privacyEye,
                  title: 'Zero Tracking',
                  subtitle: 'No analytics SDKs, trackers, or advertising IDs.',
                  colors: colors,
                  typography: typography,
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildInfoRow(
                  icon: VioraIcons.ban,
                  title: 'Completely Ad-Free',
                  subtitle: 'No banners, interruptions, or sponsored promotions.',
                  colors: colors,
                  typography: typography,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Support VIORA & Developer Donation
          Text('Support', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            onTap: () {
              Navigator.push(
                context,
                VioraPageRoute(page: const SupportVioraScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: AppDimensions.borderRadiusCompact,
                  ),
                  child: Icon(VioraIcons.supportDeveloper, color: colors.accent, size: 22),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Support VIORA', style: typography.headline),
                      const SizedBox(height: 2),
                      Text('Tip the developer & support independent development', style: typography.footnote),
                    ],
                  ),
                ),
                Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // About VIORA & Software Information
          Text('About', style: typography.title3),
          const SizedBox(height: AppDimensions.space12),
          VioraCard(
            onTap: () {
              Navigator.push(
                context,
                VioraPageRoute(page: const AboutScreen()),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppDimensions.borderRadiusCompact,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(AppConstants.appName, style: typography.headline),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'v${AppConstants.appVersion}',
                              style: TextStyle(
                                color: colors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('About VIORA, Updates, What’s New & Credits', style: typography.footnote),
                    ],
                  ),
                ),
                Icon(VioraIcons.chevronRight, color: colors.textTertiary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.bottomNavBarHeight + AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppColors colors,
    required typography,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.textSecondary),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.headline),
              const SizedBox(height: 2),
              Text(subtitle, style: typography.footnote),
            ],
          ),
        ),
      ],
    );
  }
}
