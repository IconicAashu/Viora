import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';

/// Reusable branding component for VIORA.
/// Uses the supplied original 1024x1024 high-resolution squircle logo asset.
class VioraLogo extends StatelessWidget {
  const VioraLogo({
    super.key,
    this.size = 64.0,
    this.showWordmark = false,
    this.showTagline = false,
    this.heroTag,
  });

  final double size;
  final bool showWordmark;
  final bool showTagline;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    Widget image = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    if (!showWordmark && !showTagline) {
      return image;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        image,
        if (showWordmark) ...[
          const SizedBox(height: AppDimensions.space12),
          Text(
            AppConstants.appName,
            style: typography.title1.copyWith(
              letterSpacing: 2.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: AppDimensions.space4),
          Text(
            AppConstants.appTagline,
            style: typography.subheadline.copyWith(
              color: context.colors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
