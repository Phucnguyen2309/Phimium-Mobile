import 'package:flutter/material.dart';

/// App Color Palette - "Midnight Crimson & Gold Stream" Design System
/// Spec: Primary #FF2A4D, Secondary #FFB800, Tertiary #FFD700, Neutral #8E8E93, Background #000000
class AppColors {
  AppColors._();

  // Primary palette - Crimson Red
  static const Color primary = Color(0xFFFF2A4D);
  static const Color primaryLight = Color(0xFFFF536E);
  static const Color primaryDark = Color(0xFFD91638);
  static const Color primaryMuted = Color(0x33FF2A4D); // 20% alpha

  // Secondary palette - Amber / Gold
  static const Color secondary = Color(0xFFFFB800);
  static const Color secondaryLight = Color(0xFFFFC933);
  static const Color secondaryDark = Color(0xFFD49700);
  static const Color secondaryMuted = Color(0x33FFB800);

  // Tertiary palette - Yellow Gold
  static const Color tertiary = Color(0xFFFFD700);
  static const Color tertiaryLight = Color(0xFFFFE066);

  // Neutral palette
  static const Color neutral = Color(0xFF8E8E93);
  static const Color neutralLight = Color(0xFFAEAEB2);
  static const Color neutralDark = Color(0xFF636366);

  // Background colors - Pure Black base as required by design
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF101015);
  static const Color surfaceLight = Color(0xFF181822);
  static const Color cardBackground = Color(0xFF14141B);
  static const Color cardBackgroundElevated = Color(0xFF1C1C26);
  static const Color bottomNav = Color(0xFF0A0A0E);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textHint = Color(0xFF555562);
  static const Color textDisabled = Color(0xFF3E3E4A);

  // Border & divider
  static const Color border = Color(0xFF22222E);
  static const Color borderLight = Color(0xFF2E2E3E);
  static const Color divider = Color(0xFF1C1C26);

  // Status colors
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF5856D6);

  // Badges & Special
  static const Color hotBadge = Color(0xFFFF2A4D);
  static const Color vipGold = Color(0xFFFFB800);
  static const Color vipBg = Color(0xFF2A2000);
  static const Color coinGold = Color(0xFFFFB800);
  static const Color ratingStar = Color(0xFFFFB800);
  static const Color chipInactive = Color(0xFF1A1A24);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2A4D), Color(0xFFFF536E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x40000000),
      Color(0xCC000000),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.4, 0.75, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF181822), Color(0xFF12121A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coinBannerGradient = LinearGradient(
    colors: [Color(0xFF241A0A), Color(0xFF16141F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
