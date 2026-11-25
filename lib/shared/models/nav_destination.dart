import 'package:flutter/widgets.dart';
import '../../core/theme/viora_icons.dart';

enum NavDestination {
  home(
    label: 'Home',
    icon: VioraIcons.home,
    activeIcon: VioraIcons.home,
  ),
  library(
    label: 'Library',
    icon: VioraIcons.library,
    activeIcon: VioraIcons.library,
  ),
  collections(
    label: 'Collections',
    icon: VioraIcons.collections,
    activeIcon: VioraIcons.collections,
  ),
  settings(
    label: 'Settings',
    icon: VioraIcons.settings,
    activeIcon: VioraIcons.settings,
  );

  const NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
