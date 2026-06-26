import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: Colors.transparent,

      // AppBar hidden behind glass header — keep minimal style
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // Cards inherit glass styling; keep Material theme minimal
      cardTheme: CardThemeData(
        color: Colors.white.withAlpha(180),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      // Elevated button — solid indigo, used for primary actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Input fields — very light grey, subtle border, indigo focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.signOut, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.signOut, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: AppColors.accent),
        prefixIconColor: AppColors.textSecondary,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.textPrimary),
        headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: AppColors.textPrimary),
        headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),

      dividerTheme: const DividerThemeData(
          thickness: 1, space: 1, color: Color(0xFFE5E7EB)),
    );
  }
}
