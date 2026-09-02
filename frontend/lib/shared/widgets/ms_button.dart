import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/motion.dart';

enum MsButtonVariant { primary, secondary, ghost, glass }

enum MsButtonSize { sm, md, lg }

class MsButton extends StatefulWidget {
  const MsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MsButtonVariant.primary,
    this.size = MsButtonSize.md,
    this.leading,
    this.trailing,
    this.fullWidth = false,
    this.loading = false,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final MsButtonVariant variant;
  final MsButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool fullWidth;
  final bool loading;
  final bool disabled;

  @override
  State<MsButton> createState() => _MsButtonState();
}

class _MsButtonState extends State<MsButton> {
  bool _pressed = false;

  double get _height {
    switch (widget.size) {
      case MsButtonSize.sm:
        return 36;
      case MsButtonSize.md:
        return 44;
      case MsButtonSize.lg:
        return 52;
    }
  }

  EdgeInsets get _padding {
    final isIconOnly = widget.label.isEmpty;
    switch (widget.size) {
      case MsButtonSize.sm:
        return isIconOnly
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case MsButtonSize.md:
        return isIconOnly
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case MsButtonSize.lg:
        return isIconOnly
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case MsButtonSize.sm:
        return AppTypography.captionSemiBold;
      case MsButtonSize.md:
      case MsButtonSize.lg:
        return AppTypography.bodySemiBold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.disabled || widget.loading;
    final hasLabel = widget.label.isNotEmpty;

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite;

        final textWidget = hasLabel
            ? Text(
                widget.label,
                style: _textStyle.copyWith(color: _contentColor(isDark)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null;

        return Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _contentColor(isDark),
                  ),
                ),
              )
            else ...[
              if (widget.leading != null) ...[
                widget.leading!,
                if (hasLabel) const SizedBox(width: AppSpacing.sp2),
              ],
              if (hasLabel)
                hasBoundedWidth ? Flexible(child: textWidget!) : textWidget!,
              if (widget.trailing != null) ...[
                if (hasLabel) const SizedBox(width: AppSpacing.sp2),
                widget.trailing!,
              ],
            ],
          ],
        );
      },
    );

    Widget button;

    switch (widget.variant) {
      case MsButtonVariant.primary:
        button = _buildContainer(
          child: content,
          color: isDisabled
              ? AppColors.signal.withOpacity(0.4)
              : AppColors.signal,
          border: null,
        );
      case MsButtonVariant.secondary:
        button = _buildContainer(
          child: content,
          color: isDark ? AppColors.ink2 : AppColors.paper1,
          border: Border.all(
            color: isDark ? AppColors.inkLine : AppColors.paperLine,
          ),
        );
      case MsButtonVariant.ghost:
        button = _buildContainer(
          child: content,
          color: Colors.transparent,
          border: null,
        );
      case MsButtonVariant.glass:
        button = ClipRRect(
          borderRadius: AppRadius.controlRR,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: _buildContainer(
              child: content,
              color: (isDark ? AppColors.ink1 : AppColors.paper1)
                  .withOpacity(0.6),
              border: Border.all(
                color: (isDark ? AppColors.inkLine : AppColors.paperLine)
                    .withOpacity(0.5),
              ),
            ),
          ),
        );
    }

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && !isDisabled ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: widget.fullWidth
              ? SizedBox(width: double.infinity, child: button)
              : button,
        ),
      ),
    );
  }

  Widget _buildContainer({
    required Widget child,
    required Color color,
    required Border? border,
  }) {
    return Container(
      height: _height,
      padding: _padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.controlRR,
        border: border,
      ),
      child: child,
    );
  }

  Color _contentColor(bool isDark) {
    switch (widget.variant) {
      case MsButtonVariant.primary:
        return Colors.white;
      case MsButtonVariant.secondary:
        return isDark ? AppColors.fg1 : AppColors.lightFg1;
      case MsButtonVariant.ghost:
        return AppColors.signal;
      case MsButtonVariant.glass:
        return isDark ? AppColors.fg1 : AppColors.lightFg1;
    }
  }
}
