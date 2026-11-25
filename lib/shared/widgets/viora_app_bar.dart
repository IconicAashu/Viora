import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';

class VioraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VioraAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.isLargeTitle = false,
    this.showSeparator = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isLargeTitle;
  final bool showSeparator;

  @override
  Size get preferredSize => Size.fromHeight(isLargeTitle ? (subtitle != null ? 136.0 : 108.0) : 56.0);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: showSeparator
            ? Border(
                bottom: BorderSide(
                  color: colors.separator,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
          child: isLargeTitle
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(width: AppDimensions.space8),
                        ],
                        const Spacer(),
                        ...?actions,
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      title,
                      style: typography.largeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        subtitle!,
                        style: typography.subheadline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.space8),
                  ],
                )
              : SizedBox(
                  height: 54.0,
                  child: Row(
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: AppDimensions.space8),
                      ],
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: typography.headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                style: typography.footnote,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      ...?actions,
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
