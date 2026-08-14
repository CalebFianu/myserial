import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double pageGutter = 20;
  static const double stackGap = 12;
  static const double railGap = 12;
  static const double hitMin = 44;

  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 20;
  static const double sp6 = 24;
  static const double sp7 = 32;
  static const double sp8 = 40;
  static const double sp9 = 48;

  // Bottom padding so nav bar doesn't cover content
  static const double bottomContentPad = 120;
}

abstract final class AppRadius {
  static const double poster = 10;
  static const double control = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static BorderRadius get posterRR =>
      const BorderRadius.all(Radius.circular(poster));
  static BorderRadius get controlRR =>
      const BorderRadius.all(Radius.circular(control));
  static BorderRadius get cardRR =>
      const BorderRadius.all(Radius.circular(card));
  static BorderRadius get sheetRR => const BorderRadius.only(
        topLeft: Radius.circular(sheet),
        topRight: Radius.circular(sheet),
      );
  static BorderRadius get pillRR =>
      const BorderRadius.all(Radius.circular(pill));
}

/// Convenience SizedBox gaps
const Widget gap4 = SizedBox(height: AppSpacing.sp1);
const Widget gap8 = SizedBox(height: AppSpacing.sp2);
const Widget gap12 = SizedBox(height: AppSpacing.sp3);
const Widget gap16 = SizedBox(height: AppSpacing.sp4);
const Widget gap20 = SizedBox(height: AppSpacing.sp5);
const Widget gap24 = SizedBox(height: AppSpacing.sp6);
const Widget gap32 = SizedBox(height: AppSpacing.sp7);

const Widget hgap4 = SizedBox(width: AppSpacing.sp1);
const Widget hgap8 = SizedBox(width: AppSpacing.sp2);
const Widget hgap12 = SizedBox(width: AppSpacing.sp3);
const Widget hgap16 = SizedBox(width: AppSpacing.sp4);
