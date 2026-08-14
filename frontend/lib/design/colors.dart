import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark surfaces (ink scale)
  static const Color ink0 = Color(0xFF0C1014); // app background
  static const Color ink1 = Color(0xFF141A21); // card
  static const Color ink2 = Color(0xFF1D2530); // raised
  static const Color ink3 = Color(0xFF28323F); // pressed
  static const Color inkLine = Color(0xFF2E3947); // hairline borders dark

  // Pitch black variant
  static const Color pitch0 = Color(0xFF000000);
  static const Color pitch1 = Color(0xFF0B0B0D);
  static const Color pitch2 = Color(0xFF141417);
  static const Color pitch3 = Color(0xFF1D1D21);

  // Light surfaces (paper scale)
  static const Color paper0 = Color(0xFFF4F3F0); // light background
  static const Color paper1 = Color(0xFFFFFFFF);
  static const Color paperLine = Color(0xFFE4E2DC);

  // Text on dark
  static const Color fg1 = Color(0xFFF2F5F8); // body
  static const Color fg2 = Color(0xFF9AA8B7); // muted
  static const Color fg3 = Color(0xFF5C6B7C); // faint

  // Text on light
  static const Color lightFg1 = Color(0xFF171D24);
  static const Color lightFg2 = Color(0xFF5D6875);
  static const Color lightFg3 = Color(0xFF98A1AC);

  // Brand
  static const Color signal = Color(0xFFFF5C38); // coral — primary
  static const Color signalStrong = Color(0xFFE8461F);
  static const Color signalSoft = Color(0x25FF5C38); // ~14% alpha
  static const Color signalOn = Color(0xFF1A0D08);

  // Semantic
  static const Color star = Color(0xFFFFB43A); // ratings amber
  static const Color track = Color(0xFF3DD68C); // watched/progress mint
  static const Color trackSoft = Color(0x253DD68C);
  static const Color alertColor = Color(0xFFF4574D); // error/destructive
  static const Color info = Color(0xFF4CB8FF); // links/info

  // Nav glass
  static const Color navGlassDark = Color(0xDC141A21); // rgba(20,26,33,.86)
  static const Color navGlassLight = Color(0xE1FFFFFF); // rgba(255,255,255,.88)
}
