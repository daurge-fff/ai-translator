import 'package:flutter/material.dart';

class AppColors {
  // Brand Accents (Apple System Blue & Indigo)
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color primaryIndigo = Color(0xFF5856D6);
  static const Color accentCyan = Color(0xFF32ADE6);
  static const Color accentViolet = Color(0xFFAF52DE);

  // Backgrounds
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color darkBackground = Color(0xFF0D0D12);

  // iOS system grays (light)
  static const Color lightSystemGray2 = Color(0xFFAEAEB2);
  static const Color lightSystemGray3 = Color(0xFFC7C7CC);
  static const Color lightSystemGray4 = Color(0xFFD1D1D6);
  static const Color lightSystemGray5 = Color(0xFFE5E5EA);
  static const Color lightSystemGray6 = Color(0xFFF2F2F7);

  // iOS system grays (dark)
  static const Color darkSystemGray2 = Color(0xFF636366);
  static const Color darkSystemGray3 = Color(0xFF48484A);
  static const Color darkSystemGray4 = Color(0xFF3A3A3C);
  static const Color darkSystemGray5 = Color(0xFF2C2C2E);
  static const Color darkSystemGray6 = Color(0xFF1C1C1E);

  // Light Mode Glass Colors
  static Color lightGlassSurface = Colors.white.withValues(alpha: 0.65);
  static Color lightGlassBorder = Colors.white.withValues(alpha: 0.45);
  static Color lightGlassSpecular = Colors.white.withValues(alpha: 0.80);

  // Dark Mode Glass Colors
  static Color darkGlassSurface = const Color(0xFF1E1E28).withValues(alpha: 0.60);
  static Color darkGlassBorder = Colors.white.withValues(alpha: 0.12);
  static Color darkGlassSpecular = Colors.white.withValues(alpha: 0.25);

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightTextTertiary = Color(0xFFC7C7CC);
  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF98989D);
  static const Color darkTextTertiary = Color(0xFF48484A);

  // Status & Badges
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color danger = Color(0xFFFF3B30);

  static Color separator(bool isDark) =>
      isDark ? darkSystemGray4 : lightSystemGray5;

  static Color fill(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04);
}
