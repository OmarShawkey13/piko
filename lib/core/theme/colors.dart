import 'package:flutter/material.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';

class ColorsManager {
  static bool get isDark => themeCubit.isDarkMode;

  // 🎨 -------- BRAND COLORS (Modern & Vibrant) -------- //
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Soft Violet
  static const Color accent = Color(0xFFF59E0B); // Warm Amber

  // ☀️ -------- LIGHT THEME (Clean & Airy) -------- //
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep Slate
  static const Color lightTextSecondary = Color(0xFF64748B); // Cool Gray

  static const Color bubbleMeLight = Color(0xFF6366F1);
  static const Color bubbleMeLightText = Colors.white;
  static const Color bubbleOtherLight = Color(0xFFE2E8F0);
  static const Color bubbleOtherLightText = Color(0xFF1E293B);

  // 🌙 -------- DARK THEME (Premium & Deep) -------- //
  static const Color darkBackground = Color(0xFF0F172A); // Deep Navy Slate
  static const Color darkCard = Color(0xFF1E293B); // Slate Blue
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // White Cloud
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Muted Slate

  static const Color bubbleMeDark = Color(0xFF4F46E5);
  static const Color bubbleMeDarkText = Colors.white;
  static const Color bubbleOtherDark = Color(0xFF334155);
  static const Color bubbleOtherDarkText = Color(0xFFF1F5F9);

  // ⚠️ -------- STATUS & SYSTEM -------- //
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // 🔄 -------- DYNAMIC GETTERS (Auto-Switch) -------- //
  static Color get textPrimary => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color get darkWhite => isDark ? Colors.white : Colors.black;
  static Color get scaffoldBackground =>
      isDark ? darkBackground : lightBackground;
  static Color get cardColor => isDark ? darkCard : lightCard;

  // Chat Bubbles Dynamic Getters
  static Color get bubbleMe => isDark ? bubbleMeDark : bubbleMeLight;
  static Color get bubbleMeText =>
      isDark ? bubbleMeDarkText : bubbleMeLightText;
  static Color get bubbleOther => isDark ? bubbleOtherDark : bubbleOtherLight;
  static Color get bubbleOtherText =>
      isDark ? bubbleOtherDarkText : bubbleOtherLightText;

  // Custom: Line/Border Color
  static Color get borderColor =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
}
