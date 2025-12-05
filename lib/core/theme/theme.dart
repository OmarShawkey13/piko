import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: ColorsManager.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorsManager.lightBackground,
      foregroundColor: ColorsManager.lightTextPrimary,
      titleTextStyle: TextStylesManager.bold22.copyWith(
        color: ColorsManager.lightTextPrimary,
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.primary,
        foregroundColor: ColorsManager.darkTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: ColorsManager.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorsManager.darkBackground,
      foregroundColor: ColorsManager.darkTextPrimary,
      titleTextStyle: TextStylesManager.bold22.copyWith(
        color: ColorsManager.darkTextPrimary,
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.primary,
        foregroundColor: ColorsManager.darkTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
