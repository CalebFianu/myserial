import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/motion.dart';

class MsChip extends StatefulWidget {
  const MsChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leadingIcon,
    this.trailingIcon,
    this.small = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool small;

  @override
  State<MsChip> createState() => _MsChipState();
}

class _MsChipState extends State<MsChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = widget.selected
        ? AppColors.signal
        : (isDark ? AppColors.ink1 : AppColors.paper1);

    final textColor = widget.selected
        ? Colors.white
        : (isDark ? AppColors.fg2 : AppColors.lightFg2);

    final borderColor = widget.selected
        ? Colors.transparent
        : (isDark ? AppColors.inkLine : AppColors.paperLine);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: EdgeInsets.symmetric(
            horizontal: widget.small ? 10 : 14,
            vertical: widget.small ? 5 : 8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.pillRR,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leadingIcon != null) ...[
                widget.leadingIcon!,
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: (widget.small
                        ? AppTypography.micro
                        : AppTypography.caption)
                    .copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 5),
                widget.trailingIcon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MsChipGroup extends StatelessWidget {
  const MsChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.small = false,
    this.multiSelect = false,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool small;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sp2,
      runSpacing: AppSpacing.sp2,
      children: options.map((option) {
        return MsChip(
          label: option,
          selected: selected.contains(option),
          small: small,
          onTap: () {
            final newSelected = Set<String>.from(selected);
            if (newSelected.contains(option)) {
              newSelected.remove(option);
            } else {
              if (!multiSelect) newSelected.clear();
              newSelected.add(option);
            }
            onChanged(newSelected);
          },
        );
      }).toList(),
    );
  }
}
