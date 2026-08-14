import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration med = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve spring = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;

  static const double pressScale = 0.97;
}
