import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utilities/motion_utils.dart';

class VioraCard extends StatefulWidget {
  const VioraCard({
    super.key,
    required this.child,
    this.padding = AppDimensions.edgeInsetsCard,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.hasBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool hasBorder;

  @override
  State<VioraCard> createState() => _VioraCardState();
}

class _VioraCardState extends State<VioraCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isReducedMotion = MotionUtils.isReduceMotionEnabled(context);
    final effectiveRadius = widget.borderRadius ?? AppDimensions.borderRadiusCard;

    final cardContent = Material(
      color: widget.backgroundColor ?? colors.surface,
      borderRadius: effectiveRadius,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          border: widget.hasBorder
              ? Border.all(
                  color: colors.separator,
                  width: 0.5,
                )
              : null,
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) {
      return cardContent;
    }

    final double scale = (_isPressed && !isReducedMotion) ? 0.98 : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: isReducedMotion ? Duration.zero : MotionUtils.durationFast,
        curve: MotionUtils.standardCurve,
        child: cardContent,
      ),
    );
  }
}
