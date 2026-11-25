import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora/core/constants/app_constants.dart';
import 'package:viora/core/database/database.dart';
import 'package:viora/core/services/media_tracks_service.dart';
import 'package:viora/core/services/subtitle_parser.dart';
import 'package:viora/core/services/update_service.dart';
import 'package:viora/core/services/upi_donation_service.dart';
import 'package:viora/core/services/video_discovery_service.dart';
import 'package:viora/core/theme/app_theme.dart';
import 'package:viora/core/theme/color_tokens.dart';
import 'package:viora/core/utilities/formatters.dart';
import 'package:viora/features/collections/presentation/collections_screen.dart';
import 'package:viora/features/home/presentation/home_screen.dart';
import 'package:viora/features/main_scaffold.dart';
import 'package:viora/features/onboarding/presentation/splash_screen.dart';
import 'package:viora/features/settings/presentation/about_screen.dart';
import 'package:viora/features/settings/presentation/support_viora_screen.dart';
import 'package:viora/shared/models/nav_destination.dart';
import 'package:viora/shared/widgets/viora_bottom_nav_bar.dart';

void main() {
  group('VIORA Project Foundation Tests', () {
    testWidgets('SplashScreen initializes with Viora branding', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SplashScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify app name and tagline on splash screen
      expect(find.text(AppConstants.appName), findsWidgets);
      expect(find.text(AppConstants.appTagline), findsOneWidget);

      // Drain all animation & timer frames
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('MainScaffold renders navigation destinations', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const MainScaffold(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify all 4 primary navigation destinations exist in navigation bar via semantics & icons (Step 4: Icons-only navigation bar)
      for (final dest in NavDestination.values) {
        expect(find.bySemanticsLabel(dest.label), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(VioraBottomNavBar),
            matching: find.byIcon(dest.icon),
          ),
          findsOneWidget,
        );
      }
    });

    test('Design System - Semantic Colors Token Verification', () {
      final lightColors = AppColors.light();
      final darkColors = AppColors.dark();

      // Light background #F2F2F7
      expect(lightColors.background.toARGB32(), equals(0xFFF2F2F7));
      // Dark OLED background #000000
      expect(darkColors.background.toARGB32(), equals(0xFF000000));

      // Light text primary #1C1C1E
      expect(lightColors.textPrimary.toARGB32(), equals(0xFF1C1C1E));
      // Dark text primary #F5F5F7
      expect(darkColors.textPrimary.toARGB32(), equals(0xFFF5F5F7));

      // Default accent should be Violet
      expect(AccentPreset.violet.lightAccent.toARGB32(), equals(0xFFAF52DE));
      expect(AccentPreset.violet.darkAccent.toARGB32(), equals(0xFFBF5AF2));
    });

    test('Formatters test suite', () {
      expect(Formatters.formatDuration(0), equals('0:00'));
      expect(Formatters.formatDuration(65000), equals('1:05'));
      expect(Formatters.formatDuration(3665000), equals('1:01:05'));

      expect(Formatters.formatFileSize(1024), equals('1.0 KB'));
      expect(Formatters.formatFileSize(104857600), equals('100.0 MB'));

      expect(Formatters.formatResolution(1920, 1080), equals('1080p'));
      expect(Formatters.formatResolution(3840, 2160), equals('4K'));
      expect(Formatters.formatDate(DateTime(2026, 11, 24)), equals('Nov 24, 2026'));
    });

    test('UpdateService semantic version comparison', () {
      expect(UpdateService.compareVersions('1.1.0', '1.0.0'), equals(1));
      expect(UpdateService.compareVersions('1.0.0', '1.0.0'), equals(0));
      expect(UpdateService.compareVersions('1.0.0', '1.0.1'), equals(-1));
      expect(UpdateService.compareVersions('2.0.0', '1.9.9'), equals(1));
      expect(UpdateService.compareVersions('1.0.0+1', '1.0.0+2'), equals(0));
    });

    test('AppReleaseInfo parses GitHub Releases API JSON accurately', () {
      final mockGitHubJson = {
        'tag_name': 'v1.0.1',
        'name': 'VIORA 1.0.1 - Playback & UI Fixes',
        'body': 'Performance improvements.\n\nSHA-256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        'published_at': '2026-11-25T12:00:00Z',
        'assets': [
          {
            'name': 'viora-v1.0.1.apk',
            'size': 202588060,
            'browser_download_url': 'https://github.com/IconicAashu/Viora/releases/download/v1.0.1/viora-v1.0.1.apk',
          },
          {
            'name': 'viora-v1.0.1.apk.sha256',
            'size': 64,
            'browser_download_url': 'https://github.com/IconicAashu/Viora/releases/download/v1.0.1/viora-v1.0.1.apk.sha256',
          }
        ]
      };

      final release = AppReleaseInfo.fromGitHubJson(mockGitHubJson);
      expect(release.version, equals('1.0.1'));
      expect(release.title, equals('VIORA 1.0.1 - Playback & UI Fixes'));
      expect(release.apkFileName, equals('viora-v1.0.1.apk'));
      expect(release.apkDownloadUrl, equals('https://github.com/IconicAashu/Viora/releases/download/v1.0.1/viora-v1.0.1.apk'));
      expect(release.apkSizeBytes, equals(202588060));
      expect(release.sha256Checksum, equals('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'));
      expect(release.sha256AssetUrl, equals('https://github.com/IconicAashu/Viora/releases/download/v1.0.1/viora-v1.0.1.apk.sha256'));
    });

    test('AppReleaseInfo handles releases without APK asset', () {
      final mockJsonNoApk = {
        'tag_name': 'v1.0.2',
        'name': 'VIORA 1.0.2 Draft',
        'body': 'Notes',
        'published_at': '2026-11-25T12:00:00Z',
        'assets': <dynamic>[],
      };

      final release = AppReleaseInfo.fromGitHubJson(mockJsonNoApk);
      expect(release.version, equals('1.0.2'));
      expect(release.apkDownloadUrl, isNull);
    });

    testWidgets('AboutScreen renders developer credits and branding', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const AboutScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('About VIORA'), findsOneWidget);
      expect(find.text('Version ${AppConstants.appVersion} (Build ${AppConstants.appBuildNumber})'), findsOneWidget);

      await tester.scrollUntilVisible(find.text(AppConstants.developerName), 300);
      expect(find.text(AppConstants.developerName), findsOneWidget);
      expect(find.text(AppConstants.developerRole), findsOneWidget);
    });

    test('AudioTrackInfo parses native track map and formats display title', () {
      final trackMap1 = {
        'id': '0_0',
        'groupIndex': 0,
        'trackIndex': 0,
        'label': 'Hindi',
        'language': 'Hindi',
        'langCode': 'hin',
        'codec': 'AAC',
        'channels': '2.0 Stereo',
        'bitrate': 192000,
        'isSelected': true,
        'isSupported': true,
      };

      final track1 = AudioTrackInfo.fromMap(trackMap1);
      expect(track1.id, equals('0_0'));
      expect(track1.language, equals('Hindi'));
      expect(track1.codec, equals('AAC'));
      expect(track1.channels, equals('2.0 Stereo'));
      expect(track1.displayTitle, equals('Hindi — AAC 2.0 Stereo'));
      expect(track1.isSelected, isTrue);

      final trackMap2 = {
        'id': '0_1',
        'groupIndex': 0,
        'trackIndex': 1,
        'label': 'English',
        'language': 'English',
        'langCode': 'eng',
        'codec': 'AC3',
        'channels': '5.1 Surround',
        'bitrate': 384000,
        'isSelected': false,
      };

      final track2 = AudioTrackInfo.fromMap(trackMap2);
      expect(track2.displayTitle, equals('English — AC3 5.1 Surround'));
      expect(track2.isSelected, isFalse);

      final trackMapFallback = {
        'id': '1_0',
        'groupIndex': 1,
        'trackIndex': 0,
        'label': '',
        'language': '',
        'codec': 'Unknown',
        'channels': '',
      };
      final trackFallback = AudioTrackInfo.fromMap(trackMapFallback);
      expect(trackFallback.displayTitle, equals('Audio Track'));
    });

    test('SubtitleParser parses SRT subtitles with HTML cleanup and cues lookup', () {
      const srtSample = '''
1
00:00:01,000 --> 00:00:04,500
Hello <b>world</b>! Welcome to <i>VIORA</i>.

2
00:00:05,200 --> 00:00:08,000
<font color="#ffff00">Every Frame, Beautifully.</font>
''';

      final cues = SubtitleParser.parse(srtSample, extension: 'srt');
      expect(cues.length, equals(2));

      expect(cues[0].startMs, equals(1000));
      expect(cues[0].endMs, equals(4500));
      expect(cues[0].text, equals('Hello world! Welcome to VIORA.'));

      expect(cues[1].startMs, equals(5200));
      expect(cues[1].endMs, equals(8000));
      expect(cues[1].text, equals('Every Frame, Beautifully.'));

      // Test cue timestamp matching
      expect(SubtitleParser.getActiveCueText(cues, 500), isNull);
      expect(SubtitleParser.getActiveCueText(cues, 2500), equals('Hello world! Welcome to VIORA.'));
      expect(SubtitleParser.getActiveCueText(cues, 5000), isNull);
      expect(SubtitleParser.getActiveCueText(cues, 6000), equals('Every Frame, Beautifully.'));
      expect(SubtitleParser.getActiveCueText(cues, 9000), isNull);
    });

    test('SubtitleParser parses WebVTT subtitles accurately', () {
      const vttSample = '''
WEBVTT - Sample

00:01.000 --> 00:03.500
First VTT subtitle line.

00:01:10.500 --> 00:01:15.000
Second VTT subtitle with hour mark.
''';

      final cues = SubtitleParser.parse(vttSample, extension: 'vtt');
      expect(cues.length, equals(2));

      expect(cues[0].startMs, equals(1000));
      expect(cues[0].endMs, equals(3500));
      expect(cues[0].text, equals('First VTT subtitle line.'));

      expect(cues[1].startMs, equals(70500));
      expect(cues[1].endMs, equals(75000));
      expect(cues[1].text, equals('Second VTT subtitle with hour mark.'));
    });

    test('SubtitleParser parses ASS / SSA dialogues and strips styling tags', () {
      const assSample = '''
[Script Info]
Title: Sample
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:02.50,0:00:06.00,Default,,0,0,0,,{\\an8}Welcome to {\\b1}VIORA{\\b0}\\NEvery Frame, Beautifully.
''';

      final cues = SubtitleParser.parse(assSample, extension: 'ass');
      expect(cues.length, equals(1));
      expect(cues[0].startMs, equals(2500));
      expect(cues[0].endMs, equals(6000));
      expect(cues[0].text, equals('Welcome to VIORA\nEvery Frame, Beautifully.'));
    });

    test('SubtitleStyle configuration and copyWith logic', () {
      const defaultStyle = SubtitleStyle();
      expect(defaultStyle.fontSize, equals(18.0));
      expect(defaultStyle.textColor, equals(Colors.white));
      expect(defaultStyle.delayMs, equals(0));

      final customized = defaultStyle.copyWith(
        fontSize: 22.0,
        textColor: Colors.yellow,
        delayMs: 500,
      );
      expect(customized.fontSize, equals(22.0));
      expect(customized.textColor, equals(Colors.yellow));
      expect(customized.delayMs, equals(500));
    });

    test('UpiDonationService generates accurate UPI payment deep link URI', () {
      final uriNoAmount = UpiDonationService.generateUpiUri();
      expect(uriNoAmount.startsWith('upi://pay?'), isTrue);

      final parsedNoAmount = Uri.parse(uriNoAmount);
      expect(parsedNoAmount.scheme, equals('upi'));
      expect(parsedNoAmount.queryParameters['pa'], equals('iconic-aashu@ybl'));
      expect(parsedNoAmount.queryParameters['pn'], equals('VIORA Developer'));
      expect(parsedNoAmount.queryParameters['cu'], equals('INR'));
      expect(parsedNoAmount.queryParameters['tn'], equals('Support VIORA'));
      expect(parsedNoAmount.queryParameters.containsKey('am'), isFalse);

      final uriWithAmount = UpiDonationService.generateUpiUri(amount: 49.0);
      final parsedWithAmount = Uri.parse(uriWithAmount);
      expect(parsedWithAmount.queryParameters['am'], equals('49.00'));

      final uriCustomAmount = UpiDonationService.generateUpiUri(amount: 199.5);
      final parsedCustomAmount = Uri.parse(uriCustomAmount);
      expect(parsedCustomAmount.queryParameters['am'], equals('199.50'));
    });

    testWidgets('SupportVioraScreen renders branding, UPI ID and options in Light Theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SupportVioraScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Support VIORA'), findsWidgets);
      expect(find.text('Enjoying VIORA?'), findsOneWidget);
      expect(find.text(AppConstants.developerUpiId), findsOneWidget);

      // Verify preset amounts exist
      expect(find.text('₹49'), findsOneWidget);
      expect(find.text('Buy Me a Coffee'), findsWidgets);
      expect(find.text('₹99'), findsOneWidget);
      expect(find.text('Show Some Love'), findsOneWidget);
      expect(find.text('₹199'), findsOneWidget);
      expect(find.text('Support Development'), findsOneWidget);

      // Verify Pay button
      expect(find.text('Pay ₹49 via UPI'), findsOneWidget);

      // Verify Buy Me a Coffee tile
      expect(find.text('Buy Me a Coffee'), findsWidgets);
    });

    testWidgets('SupportVioraScreen renders without overflow on narrow Android screen (320px width)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const SupportVioraScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Support VIORA'), findsWidgets);
      expect(find.text('Enjoying VIORA?'), findsOneWidget);
      expect(find.text(AppConstants.developerUpiId), findsOneWidget);
      expect(find.text('Pay ₹49 via UPI'), findsOneWidget);
    });

    testWidgets('SupportVioraScreen renders correctly in Dark Theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const SupportVioraScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Support VIORA'), findsWidgets);
      expect(find.text('Enjoying VIORA?'), findsOneWidget);
      expect(find.text(AppConstants.developerUpiId), findsOneWidget);
    });
  });

  group('HomeScreen Recently Played & Layout Tests', () {
    Video makeVideo({
      required String id,
      required String title,
      int durationMs = 60000,
      int lastPlayedPositionMs = 0,
      String? resolution,
    }) {
      final now = DateTime(2026, 11, 25, 10, 0);
      return Video(
        id: id,
        filePath: '/storage/emulated/0/Movies/$id.mp4',
        title: title,
        durationMs: durationMs,
        sizeBytes: 1024 * 1024 * 10,
        dateAdded: now,
        dateModified: now,
        mimeType: 'video/mp4',
        resolution: resolution,
        lastPlayedPositionMs: lastPlayedPositionMs,
        isFavorite: false,
        isHidden: false,
      );
    }

    Widget buildHome({
      required List<Video> allVideos,
      required List<Video> continueWatching,
      required List<Video> recentlyAdded,
      required List<Video> recentlyPlayed,
      required List<Video> favorites,
      ThemeData? theme,
    }) {
      return ProviderScope(
        overrides: [
          videoDiscoveryServiceProvider.overrideWithValue(_FakeVideoDiscoveryService()),
          libraryVideosProvider.overrideWith((ref) => Stream.value(allVideos)),
          continueWatchingVideosProvider.overrideWith((ref) => Stream.value(continueWatching)),
          recentlyAddedVideosProvider.overrideWith((ref) => Stream.value(recentlyAdded)),
          recentlyPlayedVideosProvider.overrideWith((ref) => Stream.value(recentlyPlayed)),
          favoriteVideosProvider.overrideWith((ref) => Stream.value(favorites)),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          home: HomeScreen(onNavigateToLibrary: () {}),
        ),
      );
    }

    testWidgets('Empty library shows minimal empty state and hides carousels', (tester) async {
      await tester.pumpWidget(
        buildHome(
          allVideos: const [],
          continueWatching: const [],
          recentlyAdded: const [],
          recentlyPlayed: const [],
          favorites: const [],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Your Library is Empty'), findsOneWidget);
      expect(find.text('Scan Videos'), findsOneWidget);
      expect(find.text('Continue Watching'), findsNothing);
      expect(find.text('Recently Added'), findsNothing);
      expect(find.text('Recently Played'), findsNothing);
    });

    testWidgets('Recently Added videos without playback history hides Continue Watching & Recently Played', (tester) async {
      final v1 = makeVideo(id: 'v1', title: 'Nature Clip', resolution: '1080p');

      await tester.pumpWidget(
        buildHome(
          allVideos: [v1],
          continueWatching: const [],
          recentlyAdded: [v1],
          recentlyPlayed: const [],
          favorites: const [],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Recently Added'), findsOneWidget);
      expect(find.text('Nature Clip'), findsOneWidget);
      expect(find.text('Continue Watching'), findsNothing);
      expect(find.text('Recently Played'), findsNothing);
    });

    testWidgets('One recently played video + Continue Watching available renders both sections', (tester) async {
      final v1 = makeVideo(
        id: 'v1',
        title: 'Ocean Waves',
        durationMs: 120000,
        lastPlayedPositionMs: 30000,
      );

      await tester.pumpWidget(
        buildHome(
          allVideos: [v1],
          continueWatching: [v1],
          recentlyAdded: [v1],
          recentlyPlayed: [v1],
          favorites: const [],
          theme: AppTheme.dark(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Continue Watching'), findsOneWidget);
      expect(find.text('Ocean Waves'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Recently Added'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Recently Added'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recently Played'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Recently Played'), findsOneWidget);
    });

    testWidgets('Multiple recently played videos render in order below Recently Added', (tester) async {
      final v1 = makeVideo(id: 'v1', title: 'First Video', durationMs: 60000);
      final v2 = makeVideo(id: 'v2', title: 'Second Video', durationMs: 90000);

      await tester.pumpWidget(
        buildHome(
          allVideos: [v1, v2],
          continueWatching: const [],
          recentlyAdded: [v2, v1],
          recentlyPlayed: [v1, v2],
          favorites: const [],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Recently Added'), findsOneWidget);
      expect(find.text('Recently Played'), findsOneWidget);
      expect(find.text('Continue Watching'), findsNothing);

      // Verify section layout order: Quick Access < Recently Added < Recently Played
      final favoritesY = tester.getTopLeft(find.text('Favorites')).dy;
      final recentlyAddedY = tester.getTopLeft(find.text('Recently Added')).dy;
      final recentlyPlayedY = tester.getTopLeft(find.text('Recently Played')).dy;

      expect(favoritesY, lessThan(recentlyAddedY));
      expect(recentlyAddedY, lessThan(recentlyPlayedY));

      // Verify both videos appear in both carousels
      expect(find.text('First Video'), findsNWidgets(2));
      expect(find.text('Second Video'), findsNWidgets(2));
    });
  });
}

class _FakeVideoDiscoveryService implements VideoDiscoveryService {
  @override
  Future<String?> generateThumbnail({required String filePath, required String videoId}) async => null;

  @override
  Future<List<DiscoveredVideoMetadata>> scanVideos({int minDurationMs = 1000}) async => const [];

  @override
  Future<int> syncWithDatabase(AppDatabase db, {int minDurationMs = 1000}) async => 0;
}
