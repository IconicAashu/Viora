import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/onboarding/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge immersive transparent system bars
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(
    const ProviderScope(
      child: VioraApp(),
    ),
  );
}

class VioraApp extends ConsumerWidget {
  const VioraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentPreset = ref.watch(accentPresetProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(preset: accentPreset),
      darkTheme: AppTheme.dark(preset: accentPreset),
      home: const SplashScreen(),
    );
  }
}
