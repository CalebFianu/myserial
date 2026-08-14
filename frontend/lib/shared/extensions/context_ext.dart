import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/typography.dart';
import '../../design/spacing.dart';

extension BuildContextX on BuildContext {
  // ── Theme shortcuts ──────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Size & MediaQuery ────────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  double get bottomInset => MediaQuery.viewInsetsOf(this).bottom;
  double get topPadding => MediaQuery.paddingOf(this).top;
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  // ── Color helpers ────────────────────────────────────────────────────────
  Color get backgroundColor =>
      isDark ? AppColors.ink0 : AppColors.paper0;
  Color get surfaceColor =>
      isDark ? AppColors.ink1 : AppColors.paper1;
  Color get fg1 => isDark ? AppColors.fg1 : AppColors.lightFg1;
  Color get fg2 => isDark ? AppColors.fg2 : AppColors.lightFg2;
  Color get fg3 => isDark ? AppColors.fg3 : AppColors.lightFg3;
  Color get borderColor =>
      isDark ? AppColors.inkLine : AppColors.paperLine;

  // ── Text styles ──────────────────────────────────────────────────────────
  TextStyle get heroStyle =>
      isDark ? AppTypography.hero : AppTypography.heroLight;
  TextStyle get titleStyle =>
      isDark ? AppTypography.title : AppTypography.titleLight;
  TextStyle get headingStyle =>
      isDark ? AppTypography.heading : AppTypography.headingLight;
  TextStyle get bodyStyle =>
      isDark ? AppTypography.body : AppTypography.bodyLight;
  TextStyle get captionStyle =>
      isDark ? AppTypography.caption : AppTypography.captionLight;
  TextStyle get overlineStyle =>
      isDark ? AppTypography.overline : AppTypography.overlineLight;

  // ── Navigation ───────────────────────────────────────────────────────────
  NavigatorState get nav => Navigator.of(this);
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // ── Snackbar ─────────────────────────────────────────────────────────────
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.body.copyWith(color: Colors.white)),
        backgroundColor: isError ? AppColors.alertColor : AppColors.ink2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        margin: const EdgeInsets.all(AppSpacing.pageGutter),
      ),
    );
  }
}

