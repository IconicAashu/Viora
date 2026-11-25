import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'color_tokens.dart';

/// Provider for application ThemeMode (Light, Dark, System).
/// Defaults to System theme as specified in the product requirements.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadFromDatabase();
    return ThemeMode.system;
  }

  Future<void> _loadFromDatabase() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final pref = await (db.select(db.userPreferences)..where((tbl) => tbl.key.equals('theme_mode'))).getSingleOrNull();
      if (pref != null) {
        switch (pref.value) {
          case 'light':
            state = ThemeMode.light;
            break;
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'system':
            state = ThemeMode.system;
            break;
        }
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final db = ref.read(appDatabaseProvider);
      await db.into(db.userPreferences).insertOnConflictUpdate(
            UserPreferencesCompanion.insert(
              key: 'theme_mode',
              value: mode.name,
              updatedAt: DateTime.now(),
            ),
          );
    } catch (_) {}
  }
}

/// Provider for the active AccentPreset.
/// Defaults to Violet as specified in the product requirements.
final accentPresetProvider = NotifierProvider<AccentPresetNotifier, AccentPreset>(
  AccentPresetNotifier.new,
);

class AccentPresetNotifier extends Notifier<AccentPreset> {
  @override
  AccentPreset build() {
    _loadFromDatabase();
    return AccentPreset.violet;
  }

  Future<void> _loadFromDatabase() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final pref = await (db.select(db.userPreferences)..where((tbl) => tbl.key.equals('accent_preset'))).getSingleOrNull();
      if (pref != null) {
        for (final preset in AccentPreset.values) {
          if (preset.name == pref.value) {
            state = preset;
            break;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> setPreset(AccentPreset preset) async {
    state = preset;
    try {
      final db = ref.read(appDatabaseProvider);
      await db.into(db.userPreferences).insertOnConflictUpdate(
            UserPreferencesCompanion.insert(
              key: 'accent_preset',
              value: preset.name,
              updatedAt: DateTime.now(),
            ),
          );
    } catch (_) {}
  }
}

/// Provider to toggle / observe Reduce Motion preference.
final reduceMotionOverrideProvider = NotifierProvider<ReduceMotionNotifier, bool?>(
  ReduceMotionNotifier.new,
);

/// Computed Provider for boolean reduce motion state.
final reduceMotionProvider = Provider<bool>((ref) {
  final override = ref.watch(reduceMotionOverrideProvider);
  return override ?? false;
});

class ReduceMotionNotifier extends Notifier<bool?> {
  @override
  bool? build() {
    _loadFromDatabase();
    return null; // null means follow system accessibility
  }

  Future<void> _loadFromDatabase() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final pref = await (db.select(db.userPreferences)..where((tbl) => tbl.key.equals('reduce_motion'))).getSingleOrNull();
      if (pref != null) {
        state = pref.value == 'true';
      }
    } catch (_) {}
  }

  Future<void> setOverride(bool? override) async {
    state = override;
    try {
      final db = ref.read(appDatabaseProvider);
      if (override != null) {
        await db.into(db.userPreferences).insertOnConflictUpdate(
              UserPreferencesCompanion.insert(
                key: 'reduce_motion',
                value: override.toString(),
                updatedAt: DateTime.now(),
              ),
            );
      } else {
        await (db.delete(db.userPreferences)..where((tbl) => tbl.key.equals('reduce_motion'))).go();
      }
    } catch (_) {}
  }
}
