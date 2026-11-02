import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography Phimium Travel - Be Vietnam Pro (hỗ trợ tiếng Việt tốt)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.beVietnamPro(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Headings
  static TextStyle get heroTitle =>
      _base(size: 22, weight: FontWeight.w800, color: Colors.white, height: 1.2);
  static TextStyle get heading1 =>
      _base(size: 26, weight: FontWeight.w800, letterSpacing: -0.4);
  static TextStyle get heading2 => _base(size: 20, weight: FontWeight.w700);
  static TextStyle get heading3 => _base(size: 17, weight: FontWeight.w700);

  // Body
  static TextStyle get bodyLarge => _base(size: 15, weight: FontWeight.w400);
  static TextStyle get bodyMedium => _base(
      size: 13, weight: FontWeight.w400, color: AppColors.textSecondary, height: 1.45);
  static TextStyle get bodySmall =>
      _base(size: 11, weight: FontWeight.w400, color: AppColors.textHint);

  // Labels & chips
  static TextStyle get labelBold => _base(size: 13, weight: FontWeight.w700);
  static TextStyle get labelMedium => _base(size: 12, weight: FontWeight.w600);
  static TextStyle get caption =>
      _base(size: 11, weight: FontWeight.w500, color: AppColors.textSecondary);

  // Buttons & badges
  static TextStyle get buttonText =>
      _base(size: 14, weight: FontWeight.w700, color: Colors.white);
  static TextStyle get chipText =>
      _base(size: 12, weight: FontWeight.w600, letterSpacing: 0.2);
  static TextStyle get badgeText =>
      _base(size: 10, weight: FontWeight.w700, letterSpacing: 0.3);

  // Tour specific
  static TextStyle get tourTitle =>
      _base(size: 14, weight: FontWeight.w700, height: 1.3);
  static TextStyle get tourLocation =>
      _base(size: 12, weight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get price =>
      _base(size: 15, weight: FontWeight.w800, color: AppColors.priceTag);
}
