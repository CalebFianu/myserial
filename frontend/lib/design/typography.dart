import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

abstract final class AppTypography {
  // ── Display / Headings (Archivo) ────────────────────────────────────────
  static TextStyle get hero => GoogleFonts.archivo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.fg1,
        height: 1.15,
        letterSpacing: -0.3,
      );

  static TextStyle get title => GoogleFonts.archivo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.fg1,
        height: 1.2,
        letterSpacing: -0.2,
      );

  static TextStyle get heading => GoogleFonts.archivo(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.fg1,
        height: 1.25,
      );

  static TextStyle get cardTitle => GoogleFonts.archivo(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.fg1,
        height: 1.3,
      );

  // ── Body / UI (Figtree) ─────────────────────────────────────────────────
  static TextStyle get body => GoogleFonts.figtree(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.fg1,
        height: 1.5,
      );

  static TextStyle get bodySemiBold => GoogleFonts.figtree(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.fg1,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.figtree(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.fg2,
        height: 1.4,
      );

  static TextStyle get captionSemiBold => GoogleFonts.figtree(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.fg2,
        height: 1.4,
      );

  static TextStyle get micro => GoogleFonts.figtree(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.fg3,
        height: 1.35,
      );

  static TextStyle get microSemiBold => GoogleFonts.figtree(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.fg3,
        height: 1.35,
      );

  // Overline (uppercase tracking)
  static TextStyle get overline => GoogleFonts.figtree(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.fg3,
        height: 1.35,
        letterSpacing: 11 * 0.08,
      );

  // ── Monospace (JetBrains Mono) ──────────────────────────────────────────
  static TextStyle get codeStyle => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.fg2,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get codeMicro => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.fg3,
        height: 1.35,
      );

  // ── Light theme variants ────────────────────────────────────────────────
  static TextStyle get heroLight => hero.copyWith(color: AppColors.lightFg1);
  static TextStyle get titleLight => title.copyWith(color: AppColors.lightFg1);
  static TextStyle get headingLight =>
      heading.copyWith(color: AppColors.lightFg1);
  static TextStyle get bodyLight => body.copyWith(color: AppColors.lightFg1);
  static TextStyle get captionLight =>
      caption.copyWith(color: AppColors.lightFg2);
  static TextStyle get overlineLight =>
      overline.copyWith(color: AppColors.lightFg3);
}
