import 'package:flutter/material.dart';

/// Centralized color palette using Material 3 naming conventions.
/// Provides a clear separation between light and dark modes with high contrast.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Taken from existing kPrimaryColor = 0xFF2B9FE6)
  static const Color primaryLight = Color(0xFF2B9FE6);
  static const Color primaryDark = Color(0xFF4AC0FC); // Slightly lighter for contrast

  // Background Colors
  static const Color backgroundLight = Color(0xFFF9FAFB); // Very light greyish
  static const Color backgroundDark = Color(0xFF121212); // Deep rich black

  // Surface Colors (Cards, Dialogs, etc)
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E); // Elevated dark surface

  // Text Colors
  static const Color textLight = Color(0xFF111827); // Dark grey/black
  static const Color textDark = Color(0xFFF9FAFB); // Off-white

  // Semantic Colors
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);

  // Success
  static const Color successLight = Color(0xFF388E3C);
  static const Color successDark = Color(0xFF66BB6A);

  // Warning
  static const Color warningLight = Color(0xFFFFA000);
  static const Color warningDark = Color(0xFFFFCA28);

  // Dividers & Borders
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF333333);

  // --- Material 3 Color Schemes ---

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryLight,
    onPrimary: Colors.white,
    secondary: primaryLight,
    onSecondary: Colors.white,
    error: errorLight,
    onError: Colors.white,
    surface: surfaceLight,
    onSurface: textLight,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: surfaceDark,
    secondary: primaryDark,
    onSecondary: surfaceDark,
    error: errorDark,
    onError: textDark,
    surface: surfaceDark,
    onSurface: textDark,
  );
}
