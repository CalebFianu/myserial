import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'typography.dart';

abstract final class MySerialTheme {
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.ink0,
        surface: AppColors.ink1,
        surfaceVariant: AppColors.ink2,
        onSurface: AppColors.fg1,
        onSurfaceVariant: AppColors.fg2,
        outline: AppColors.inkLine,
        systemUiOverlay: SystemUiOverlayStyle.light,
      );

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.paper0,
        surface: AppColors.paper1,
        surfaceVariant: const Color(0xFFECEBE7),
        onSurface: AppColors.lightFg1,
        onSurfaceVariant: AppColors.lightFg2,
        outline: AppColors.paperLine,
        systemUiOverlay: SystemUiOverlayStyle.dark,
      );

  static ThemeData get pitchBlackTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.pitch0,
        surface: AppColors.pitch1,
        surfaceVariant: AppColors.pitch2,
        onSurface: AppColors.fg1,
        onSurfaceVariant: AppColors.fg2,
        outline: const Color(0xFF1E1E22),
        systemUiOverlay: SystemUiOverlayStyle.light,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required SystemUiOverlayStyle systemUiOverlay,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.signal,
      onPrimary: Colors.white,
      primaryContainer: AppColors.signalSoft,
      onPrimaryContainer: AppColors.signal,
      secondary: AppColors.track,
      onSecondary: isDark ? AppColors.ink0 : AppColors.paper0,
      secondaryContainer: AppColors.trackSoft,
      onSecondaryContainer: AppColors.track,
      tertiary: AppColors.star,
      onTertiary: isDark ? AppColors.ink0 : AppColors.paper0,
      tertiaryContainer: const Color(0x25FFB43A),
      onTertiaryContainer: AppColors.star,
      error: AppColors.alertColor,
      onError: Colors.white,
      errorContainer: const Color(0x25F4574D),
      onErrorContainer: AppColors.alertColor,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outline.withOpacity(0.5),
      shadow: Colors.black.withOpacity(0.4),
      scrim: Colors.black.withOpacity(0.6),
      inverseSurface: isDark ? AppColors.paper0 : AppColors.ink1,
      onInverseSurface: isDark ? AppColors.lightFg1 : AppColors.fg1,
      inversePrimary: AppColors.signalStrong,
    );

    final baseTextTheme = TextTheme(
      displayLarge: AppTypography.hero,
      displayMedium: AppTypography.hero.copyWith(fontSize: 24),
      displaySmall: AppTypography.title,
      headlineLarge: AppTypography.title,
      headlineMedium: AppTypography.heading,
      headlineSmall: AppTypography.heading.copyWith(fontSize: 15),
      titleLarge: AppTypography.cardTitle,
      titleMedium: AppTypography.bodySemiBold,
      titleSmall: AppTypography.captionSemiBold,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
      labelLarge: AppTypography.bodySemiBold,
      labelMedium: AppTypography.captionSemiBold,
      labelSmall: AppTypography.micro,
    );

    final textTheme = isDark
        ? baseTextTheme
        : baseTextTheme.apply(
            bodyColor: AppColors.lightFg1,
            displayColor: AppColors.lightFg1,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.figtreeTextTheme(textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: systemUiOverlay,
        titleTextStyle: AppTypography.heading.copyWith(
          color: isDark ? AppColors.fg1 : AppColors.lightFg1,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.fg1 : AppColors.lightFg1,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.signal,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.bodySemiBold.copyWith(color: Colors.white),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.fg1 : AppColors.lightFg1,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: outline),
          textStyle: AppTypography.bodySemiBold,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.signal,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: AppTypography.bodySemiBold.copyWith(
            color: AppColors.signal,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.signal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.alertColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.body.copyWith(color: onSurfaceVariant),
        labelStyle:
            AppTypography.caption.copyWith(color: onSurfaceVariant),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.signal;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.signal,
        labelStyle: AppTypography.caption,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: false,
        dragHandleColor: onSurfaceVariant,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.signalSoft,
        labelTextStyle: WidgetStateProperty.all(AppTypography.micro),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.signal;
          return outline;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.signal,
        linearTrackColor: AppColors.ink3,
      ),
    );
  }
}
