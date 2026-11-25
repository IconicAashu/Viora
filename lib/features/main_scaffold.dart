import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_provider.dart';
import '../core/utilities/motion_utils.dart';
import '../shared/widgets/viora_bottom_nav_bar.dart';
import 'collections/presentation/collections_screen.dart';
import 'home/presentation/home_screen.dart';
import 'library/presentation/library_screen.dart';
import 'settings/presentation/settings_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);

      final isReducedMotion = ref.read(reduceMotionProvider);
      if (isReducedMotion) {
        _pageController.jumpToPage(index);
      } else {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 260),
          curve: MotionUtils.standardCurve,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Only programmatic tab switching
        children: [
          _KeepAliveTab(
            child: HomeScreen(
              onNavigateToLibrary: () => _onTabTapped(1),
              onNavigateToSettings: () => _onTabTapped(3),
            ),
          ),
          const _KeepAliveTab(child: LibraryScreen()),
          const _KeepAliveTab(child: CollectionsScreen()),
          const _KeepAliveTab(child: SettingsScreen()),
        ],
      ),
      bottomNavigationBar: VioraBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// Keeps state, scroll position, and search queries active when switching between tabs
class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({required this.child});

  final Widget child;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
