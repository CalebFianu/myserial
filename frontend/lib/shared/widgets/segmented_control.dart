import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/motion.dart';

class SegmentedControl extends StatefulWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 36,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  State<SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.ink2 : AppColors.paper1;
    final pillColor = isDark ? AppColors.ink3 : const Color(0xFFFFFFFF);
    final borderColor = isDark ? AppColors.inkLine : AppColors.paperLine;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.controlRR,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / widget.options.length;

          return Stack(
            children: [
              // Animated pill indicator
              AnimatedPositioned(
                duration: AppMotion.fast,
                curve: AppMotion.spring,
                left: widget.selectedIndex * itemWidth + 2,
                top: 2,
                bottom: 2,
                width: itemWidth - 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(
                        AppRadius.control - 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Labels
              Row(
                children: List.generate(widget.options.length, (i) {
                  final isSelected = i == widget.selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppMotion.fast,
                          style: AppTypography.captionSemiBold.copyWith(
                            color: isSelected
                                ? (isDark ? AppColors.fg1 : AppColors.lightFg1)
                                : (isDark ? AppColors.fg3 : AppColors.lightFg3),
                          ),
                          child: Text(widget.options[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
