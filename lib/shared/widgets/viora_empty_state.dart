import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';

class VioraEmptyState extends StatelessWidget {
  const VioraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.separator, width: 0.5),
              ),
              child: Icon(
                icon,
                size: 32,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
            Text(
              title,
              style: typography.title2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              description,
              style: typography.subheadline.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppDimensions.space24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
