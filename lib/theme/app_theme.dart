import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFF6F6F8);
  static const primary = Color(0xFF9DB7FF);
  static const secondary = Color(0xFFE58BF2);
  static const accent = Color(0xFFF28C28);
  static const yellow = Color(0xFFF0BC4E);
  static const dark = Color(0xFF0D0D0D);
  static const surface = Colors.white;
  static const textSecondary = Color(0xFF8A8A8A);
  static const danger = Color(0xFFE5484D);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.dark,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.accent.withValues(alpha: 0.2),
      ),
    );
  }
}
