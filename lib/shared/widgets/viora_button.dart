import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utilities/motion_utils.dart';

enum VioraButtonVariant {
  primary,
  secondary,
  tertiary,
  destructive,
}

class VioraButton extends StatefulWidget {
  const VioraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = VioraButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VioraButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  State<VioraButton> createState() => _VioraButtonState();
}

class _VioraButtonState extends State<VioraButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails _) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isReducedMotion = MotionUtils.isReduceMotionEnabled(context);

    // Compute colors based on variant
    final Color backgroundColor;
    final Color foregroundColor;
    final Border? border;

    switch (widget.variant) {
      case VioraButtonVariant.primary:
        backgroundColor = _isEnabled ? colors.accent : colors.accent.withValues(alpha: 0.4);
        foregroundColor = Colors.white;
        border = null;
        break;
      case VioraButtonVariant.secondary:
        backgroundColor = _isEnabled
            ? colors.surfaceSecondary
            : colors.surfaceSecondary.withValues(alpha: 0.4);
        foregroundColor = _isEnabled ? colors.textPrimary : colors.textTertiary;
        border = Border.all(color: colors.separator, width: 0.5);
        break;
      case VioraButtonVariant.tertiary:
        backgroundColor = Colors.transparent;
        foregroundColor = _isEnabled ? colors.accent : colors.textTertiary;
        border = null;
        break;
      case VioraButtonVariant.destructive:
        backgroundColor = _isEnabled
            ? colors.danger.withValues(alpha: 0.15)
            : colors.danger.withValues(alpha: 0.05);
        foregroundColor = _isEnabled ? colors.danger : colors.danger.withValues(alpha: 0.4);
        border = Border.all(color: colors.danger.withValues(alpha: 0.3), width: 0.5);
        break;
    }

    // Scale down subtly on press unless motion is reduced
    final double scale = (_isPressed && !isReducedMotion) ? 0.97 : 1.0;

    final Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: foregroundColor,
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
        ] else if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: AppDimensions.space8),
        ],
        Text(
          widget.label,
          style: typography.headline.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.minTouchTarget,
        minWidth: AppDimensions.minTouchTarget,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: scale,
          duration: isReducedMotion ? Duration.zero : MotionUtils.durationFast,
          curve: MotionUtils.standardCurve,
          child: AnimatedContainer(
            duration: isReducedMotion ? Duration.zero : MotionUtils.durationFast,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppDimensions.borderRadiusButton,
              border: border,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Accessible icon-only button adhering to 44x44 minimum touch target.
class VioraIconButton extends StatelessWidget {
  const VioraIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.backgroundColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: AppDimensions.minTouchTarget,
              height: AppDimensions.minTouchTarget,
              alignment: Alignment.center,
              decoration: backgroundColor != null
                  ? BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
