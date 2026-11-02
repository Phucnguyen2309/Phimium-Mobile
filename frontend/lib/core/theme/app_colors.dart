import 'package:flutter/material.dart';

/// Bảng màu Phimium Travel - đồng bộ thiết kế Web ("Saigon Royal Navy & Golden Amber")
///
/// Primary   #162456 (Blue 950 - Navy chủ đạo của Web)
/// Secondary #FDC700 (Yellow 400 - Vàng điểm nhấn của Web)
/// Background #F8FAFC (Slate 50 - Nền sáng hiện đại của Web)
class AppColors {
  AppColors._();

  // Primary - Royal Navy (blue-950 / blue-900)
  static const Color primary = Color(0xFF162456);
  static const Color primaryLight = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryMuted = Color(0x14162456); // ~8% alpha

  // Secondary - Golden Yellow (yellow-400 / amber)
  static const Color secondary = Color(0xFFFDC700);
  static const Color secondaryLight = Color(0xFFFDE047);
  static const Color secondaryDark = Color(0xFFB45309);
  static const Color secondaryMuted = Color(0x24FDC700);

  // Tertiary - Warm Amber
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color tertiaryLight = Color(0xFFFDE68A);

  // Neutral (Slate)
  static const Color neutral = Color(0xFF64748B);
  static const Color neutralLight = Color(0xFFCBD5E1);
  static const Color neutralDark = Color(0xFF334155);

  // Backgrounds (Slate 50 & White)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundElevated = Color(0xFFFFFFFF);
  static const Color bottomNav = Color(0xFFFFFFFF);

  // Text (Slate 900 / 600 / 400)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & divider (Slate 200 / 100)
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Status (Emerald / Rose / Amber / Blue)
  static const Color error = Color(0xFFE11D48);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // Travel-specific
  static const Color foodTour = Color(0xFFEA580C); // Ẩm thực - Cam Coral nổi bật
  static const Color historyTour = Color(0xFF2563EB); // Văn hóa & Lịch sử - Royal Blue
  static const Color ratingStar = Color(0xFFF59E0B);
  static const Color chipInactive = Color(0xFFF1F5F9);
  static const Color priceTag = Color(0xFF162456);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF162456), Color(0xFF1E3A8A), Color(0xFF254299)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFF162456), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFDC700), Color(0xFFF59E0B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Lớp phủ tối dưới ảnh để chữ trắng dễ đọc
  static const LinearGradient imageOverlay = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x400F172A),
      Color(0xD90F172A),
    ],
    stops: [0.0, 0.45, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient placeholderGradient = LinearGradient(
    colors: [Color(0xFF162456), Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
