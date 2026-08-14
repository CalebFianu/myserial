import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

enum MsBadgeVariant { signal, neutral, outline, track, star }

class MsBadge extends StatelessWidget {
  const MsBadge({
    super.key,
    required this.label,
    this.variant = MsBadgeVariant.neutral,
    this.small = false,
    this.leadingDot = false,
  });

  final String label;
  final MsBadgeVariant variant;
  final bool small;
  final bool leadingDot;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case MsBadgeVariant.signal:
        bgColor = AppColors.signalSoft;
        textColor = AppColors.signal;
      case MsBadgeVariant.neutral:
        bgColor = isDark ? AppColors.ink2 : AppColors.paper1;
        textColor = isDark ? AppColors.fg2 : AppColors.lightFg2;
      case MsBadgeVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.fg2 : AppColors.lightFg2;
        border = Border.all(
          color: isDark ? AppColors.inkLine : AppColors.paperLine,
          width: 1,
        );
      case MsBadgeVariant.track:
        bgColor = AppColors.trackSoft;
        textColor = AppColors.track;
      case MsBadgeVariant.star:
        bgColor = const Color(0x25FFB43A);
        textColor = AppColors.star;
    }

    final hPad = small ? 6.0 : 8.0;
    final vPad = small ? 2.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.pillRR,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: (small ? AppTypography.codeMicro : AppTypography.micro)
                .copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
