import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Colores base inmutables
  static const primary = Color(0xFF6EE718);
  static const background = Color(0xFF0D110E);
  static const surface = Color(0xFF161B14);
  static const surfaceVariant = Color(0xFF1D2616);
  static const border = Color(0xFF2F3829);
  static const onBackground = Color(0xFFF7F8F6);
  static const onSurface = Color(0xFFE6E6E6);
  static const muted = Color(0xFF8B9A8F);
  static const error = Color(0xFFB71C1C);
}

class AppTheme {
  AppTheme._();

  static ThemeData getTheme({required bool isHighContrast}) {
    // Definimos los colores dinamicos. En alto contraste usamos negros puros y blancos puros.
    final currentBackground = isHighContrast ? const Color(0xFF000000) : AppColors.background;
    final currentSurface = isHighContrast ? const Color(0xFF000000) : AppColors.surface;
    final currentBorder = isHighContrast ? AppColors.primary : AppColors.border;
    final currentMuted = isHighContrast ? const Color(0xFFCCCCCC) : AppColors.muted;
    final currentOnBackground = isHighContrast ? const Color(0xFFFFFFFF) : AppColors.onBackground;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: currentBackground,
      secondary: AppColors.primary,
      onSecondary: currentBackground,
      error: AppColors.error,
      onError: currentBackground,
      surface: currentSurface,
      onSurface: currentOnBackground,
      surfaceContainerHighest: AppColors.surfaceVariant,
      outline: currentBorder,
      outlineVariant: currentBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: currentBackground,
      fontFamily: 'SpaceGrotesk',

      appBarTheme: AppBarTheme(
        backgroundColor: currentBackground,
        foregroundColor: currentOnBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: currentOnBackground,
        ),
      ),

      cardTheme: CardThemeData(
        color: currentSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: currentBorder, width: isHighContrast ? 2 : 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: currentBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: currentBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: currentBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        hintStyle: TextStyle(color: currentMuted, fontSize: 14),
        prefixIconColor: currentMuted,
      ),

      dividerTheme: DividerThemeData(
        color: currentBorder,
        thickness: isHighContrast ? 2 : 1,
        space: 0,
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(color: currentOnBackground, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: currentOnBackground, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(color: currentOnBackground, fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge: TextStyle(color: currentOnBackground, fontSize: 15),
        bodyMedium: TextStyle(color: currentOnBackground, fontSize: 13),
        bodySmall: TextStyle(color: currentMuted, fontSize: 11),
        labelSmall: TextStyle(color: currentMuted, fontSize: 10, letterSpacing: 1.0),
      ),
    );
  }
}