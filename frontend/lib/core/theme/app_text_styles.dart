import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App-wide typography presets using Plus Jakarta Sans
/// Consistent with the "Midnight Crimson & Gold Stream" design system
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle get heroTitle => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  // Labels & Chips
  static TextStyle get labelBold => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Buttons & Badges
  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get chipText => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  static TextStyle get badgeText => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      );

  // Drama Specific
  static TextStyle get dramaTitle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get episodeCount => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral,
      );

  static TextStyle get rankNumber => GoogleFonts.plusJakartaSans(
        fontSize: 54,
        fontWeight: FontWeight.w900,
        height: 0.9,
      );
}
