import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple-style translucent material container featuring BackdropFilter blur,
/// subtle surface luminance tint, fine light-catching edge borders, and depth shadows.
class VioraGlassSurface extends StatelessWidget {
  const VioraGlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.blur = 24.0,
    this.saturation = 1.8,
    this.opacity,
    this.padding,
    this.border,
    this.boxShadow,
    this.color,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double blur;
  final double saturation;
  final double? opacity;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16.0);

    // Apple HIG frosted material colors
    final baseColor = color ??
        (isDark
            ? Color.fromRGBO(28, 28, 30, opacity ?? 0.75)
            : Color.fromRGBO(255, 255, 255, opacity ?? 0.80));

    final effectiveBorder = border ??
        Border.all(
          color: isDark
              ? const Color.fromRGBO(255, 255, 255, 0.12)
              : const Color.fromRGBO(255, 255, 255, 0.65),
          width: 0.5,
        );

    final effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: isDark ? const Color(0x66000000) : const Color(0x14000000),
            blurRadius: 20.0,
            offset: const Offset(0, 6),
          ),
        ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: radius,
              border: effectiveBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
