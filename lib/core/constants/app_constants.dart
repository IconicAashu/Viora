/// Application-wide constants and configuration for VIORA.
abstract final class AppConstants {
  static const String appName = 'VIORA';
  static const String appTagline = 'Every Frame, Beautifully.';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String appPackageName = 'com.viora.viora';
  static const String appReleaseDate = 'November 2026';

  // Database
  static const String databaseName = 'viora_local.sqlite';
  static const int databaseSchemaVersion = 1;

  // Preferences Keys
  static const String prefKeyThemeMode = 'viora_pref_theme_mode';
  static const String prefKeyAccentColor = 'viora_pref_accent_color';
  static const String prefKeyReduceMotion = 'viora_pref_reduce_motion';
  static const String prefKeyLastUpdateCheck = 'viora_pref_last_update_check';

  // Developer Credits
  static const String developerName = 'Aashu Kumar';
  static const String developerRole = 'Creator & Developer of VIORA';
  static const String developerGitHub = 'https://github.com/IconicAashu';
  static const String developerEmail = 'aashu@hilmail.co';
  static const String projectRepository = 'https://github.com/IconicAashu/Viora';

  // Support & Developer Donation Configuration
  static const String developerUpiId = 'iconic-aashu@ybl';
  static const String developerUpiName = 'VIORA Developer';
  static const String upiTransactionNote = 'Support VIORA';
  static const String upiCurrency = 'INR';
  /// Configurable external donation link (kept unconfigured until developer provides their official page)
  static const String? buyMeACoffeeUrl = null;

  // Product Description
  static const String appDescription =
      'VIORA is a thoughtfully designed video player built around simplicity, privacy, and a beautiful viewing experience.\n\nYour videos stay on your device. No mandatory account, no cloud uploads, and no advertisements.';

  // Update System Configuration — Official GitHub Releases API
  static const String updateMetadataUrl =
      'https://api.github.com/repos/IconicAashu/Viora/releases/latest';
  static const String gitHubRepositoryUrl =
      'https://github.com/IconicAashu/Viora';
  static const String gitHubReleasesUrl =
      'https://github.com/IconicAashu/Viora/releases';

  // Structured changelog for What's New
  static const List<Map<String, dynamic>> changelog = [
    {
      'version': '1.0.0',
      'date': 'November 24, 2026',
      'isCurrent': true,
      'highlights': [
        'Initial production release of VIORA',
        'Hardware-accelerated Media3/ExoPlayer video engine',
        'Automatic rotation metadata & landscape/portrait detection',
        'Fluid gestures: double-tap seek (±10s), brightness & volume swipe',
        'Interactive seekbar with live buffered progress visualization',
        'Picture-in-Picture (PiP) and custom aspect ratio controls',
        'Biometric-ready Private Vault and offline backup export/import',
        'Apple-inspired minimal design system with dark OLED mode',
      ],
      'bugFixes': [
        'Fixed portrait video layout viewport positioning',
        'Fixed top control toolbar 22px overflow in portrait mode',
        'Resolved seekbar touch dragging and gesture arena contention',
        'Corrected finished video filtering in Continue Watching carousel',
      ],
    },
  ];
}
