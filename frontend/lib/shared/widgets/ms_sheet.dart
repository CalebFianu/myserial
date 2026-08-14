import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

class MsSheet extends StatelessWidget {
  const MsSheet({
    super.key,
    this.title,
    required this.child,
    this.trailing,
    this.showHandle = true,
    this.showCloseButton = true,
    this.backgroundColor,
    this.minHeight,
    this.maxHeight,
  });

  final String? title;
  final Widget child;
  final Widget? trailing;
  final bool showHandle;
  final bool showCloseButton;
  final Color? backgroundColor;
  final double? minHeight;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.ink1 : AppColors.paper1);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ??
            MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.sheetRR,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + header
          if (showHandle)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.fg3 : AppColors.lightFg3,
                    borderRadius: AppRadius.pillRR,
                  ),
                ),
              ),
            ),

          if (title != null || showCloseButton)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                12,
                AppSpacing.pageGutter,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: title != null
                        ? Text(title!, style: AppTypography.heading)
                        : const SizedBox.shrink(),
                  ),
                  if (trailing != null) trailing!,
                  if (showCloseButton)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.ink2 : AppColors.paper0,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color:
                              isDark ? AppColors.fg2 : AppColors.lightFg2,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.sp3),
          Flexible(child: child),
          SizedBox(height: bottomPad + AppSpacing.sp3),
        ],
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    Widget? trailing,
    bool showHandle = true,
    bool showCloseButton = true,
    Color? backgroundColor,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => MsSheet(
        title: title,
        trailing: trailing,
        showHandle: showHandle,
        showCloseButton: showCloseButton,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }
}
