import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';

enum VioraIconSize {
  small(AppDimensions.iconSmall),
  medium(AppDimensions.iconMedium),
  large(AppDimensions.iconLarge),
  xlarge(AppDimensions.iconXLarge);

  const VioraIconSize(this.value);
  final double value;
}

/// Unified icon component following `design-system.md`:
/// - Minimalist outline language.
/// - Standard size scale: 16, 20, 24, 32 pt.
/// - Defaults to semantic primary text color.
class VioraIcon extends StatelessWidget {
  const VioraIcon(
    this.icon, {
    super.key,
    this.size = VioraIconSize.medium,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final VioraIconSize size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size.value,
      color: color ?? context.colors.textPrimary,
      semanticLabel: semanticLabel,
    );
  }
}
