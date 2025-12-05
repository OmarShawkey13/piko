import 'package:flutter/material.dart';

class ColorsManager {
  // -------- PRIMARY COLORS -------- //
  static const Color primary = Color(0xFF4A56E2);
  static const Color secondary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFFFFB800);

  // -------- LIGHT THEME -------- //
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1B1B1D);
  static const Color lightTextSecondary = Color(0xFF6F6F79);
  static const Color bubbleMeLight = Color(0xFF4A56E2); // primary
  static const Color bubbleMeLightText = Colors.white;
  static const Color bubbleOtherLight = Color(0xFFF0F1F5); // أفتح من lightCard
  static const Color bubbleOtherLightText = Color(0xFF1B1B1D); // lightTextPrimary

  // -------- DARK THEME -------- //
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFEDEDED);
  static const Color darkTextSecondary = Color(0xFF9D9DA6);
  static const Color bubbleMeDark = Color(0xFF4A56E2); // primary نفسها
  static const Color bubbleMeDarkText = Colors.white;
  static const Color bubbleOtherDark = Color(0xFF1E1E1E); // darkCard
  static const Color bubbleOtherDarkText = Color(0xFFEDEDED); // darkTextPrimary

  // -------- SHARED -------- //
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
}
