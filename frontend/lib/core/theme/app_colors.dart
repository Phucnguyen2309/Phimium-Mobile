import 'package:flutter/material.dart';

/// Bảng màu Phimium Travel - "Saigon Jade & Saffron"
/// Lấy cảm hứng từ hàng cây xanh, sông Sài Gòn (xanh ngọc) và
/// ánh đèn đường phố / ẩm thực (cam nghệ), nền kem ấm như tường gạch cũ.
///
/// Primary  #0E7C66 (xanh ngọc)   Secondary #E8833A (cam nghệ)
/// Tertiary #F6C453 (vàng nắng)   Background #FAF7F2 (kem ấm)
class AppColors {
  AppColors._();

  // Primary - Jade green
  static const Color primary = Color(0xFF0E7C66);
  static const Color primaryLight = Color(0xFF14A085);
  static const Color primaryDark = Color(0xFF0A5C4C);
  static const Color primaryMuted = Color(0x1F0E7C66); // ~12% alpha

  // Secondary - Saffron orange
  static const Color secondary = Color(0xFFE8833A);
  static const Color secondaryLight = Color(0xFFF2A766);
  static const Color secondaryDark = Color(0xFFC4672A);
  static const Color secondaryMuted = Color(0x1FE8833A);

  // Tertiary - Sunshine yellow
  static const Color tertiary = Color(0xFFF6C453);
  static const Color tertiaryLight = Color(0xFFFBDD94);

  // Neutral
  static const Color neutral = Color(0xFF8A9499);
  static const Color neutralLight = Color(0xFFB9C1C4);
  static const Color neutralDark = Color(0xFF5F6B70);

  // Backgrounds
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF3EEE6);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundElevated = Color(0xFFFFFDF9);
  static const Color bottomNav = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF5F6B70);
  static const Color textHint = Color(0xFF9AA3A7);
  static const Color textDisabled = Color(0xFFC5CBCE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & divider
  static const Color border = Color(0xFFE6E0D6);
  static const Color borderLight = Color(0xFFEFEAE2);
  static const Color divider = Color(0xFFECE6DC);

  // Status
  static const Color error = Color(0xFFD64545);
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE8A33A);
  static const Color info = Color(0xFF2F80ED);

  // Travel-specific
  static const Color foodTour = Color(0xFFE8833A); // Food tour - cam
  static const Color historyTour = Color(0xFF8B5E3C); // History tour - nâu sepia
  static const Color ratingStar = Color(0xFFF5B301);
  static const Color chipInactive = Color(0xFFF3EEE6);
  static const Color priceTag = Color(0xFF0A5C4C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0E7C66), Color(0xFF14A085)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFE8833A), Color(0xFFF6C453)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Lớp phủ tối dưới ảnh để chữ trắng dễ đọc
  static const LinearGradient imageOverlay = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x33000000),
      Color(0xB3000000),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient placeholderGradient = LinearGradient(
    colors: [Color(0xFFDDEFE9), Color(0xFFF7E6D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
