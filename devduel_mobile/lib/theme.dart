import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core backgrounds from Tailwind config
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF121414);
  static const Color surfaceContainer = Color(0xFF1E2020);
  static const Color surfaceContainerLow = Color(0xFF1A1C1C);
  static const Color surfaceContainerHigh = Color(0xFF292A2A);
  static const Color surfaceContainerHighest = Color(0xFF343535);
  static const Color surfaceContainerLowest = Color(0xFF0D0E0F);

  // Primary (Gold/Yellow theme)
  static const Color primary = Color(0xFFFFF6DF);
  static const Color primaryContainer = Color(0xFFFFD700);
  static const Color onPrimaryContainer = Color(0xFF705E00);
  static const Color primaryFixedDim = Color(0xFFE9C400);

  // Cards and Containers
  static const Color cardBg = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF27272A); // Zinc 800
  static const Color outline = Color(0xFF71717A); // Zinc 500
  static const Color outlineVariant = Color(0xFF27272A); // Zinc 800

  // Secondary (Amber/Gold accent)
  static const Color secondary = Color(0xFFF7BD48);
  static const Color secondaryContainer = Color(0xFFBA880F);
  static const Color onSecondary = Color(0xFF412D00);

  // Semantic Colors
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFFFFFFFF);

  // On-colors
  static const Color onSurface = Color(0xFFE3E2E2);
  static const Color onSurfaceVariant = Color(0xFFD0C6AB);
  static const Color onBackground = Color(0xFFE3E2E2);

  // Difficulty Colors
  static const Color easy = Color(0xFF4ADE80);
  static const Color easyBg = Color(0xFF064E3B);
  static const Color medium = Color(0xFFFACC15);
  static const Color mediumBg = Color(0xFF713F12);
  static const Color hard = Color(0xFFF87171);
  static const Color hardBg = Color(0xFF7F1D1D);

  // Zinc equivalents (Utility)
  static const Color zinc950 = Color(0xFF09090B);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc400 = Color(0xFFA1A1AA);

  // Podium/Rank Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFA0A0A0);
  static const Color bronze = Color(0xFFCD7F32);
}

class AppTheme {
  // Text Styles from Tailwind font-sizes
  static TextStyle get headlineLg => GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.64, // -0.02em
        height: 1.25, // 40px line-height
      );

  static TextStyle get headlineMd => GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
        letterSpacing: -0.24, // -0.01em
        height: 1.33, // 32px line-height
      );

  static TextStyle get bodyLg => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
        height: 1.5, // 24px line-height
      );

  static TextStyle get bodyMd => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
        height: 1.42, // 20px line-height
      );

  static TextStyle get labelCaps => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: 1.2, // 0.1em
        height: 1.33, // 16px line-height
      );

  static TextStyle get codeBlock => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
        height: 1.57, // 22px line-height
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimaryContainer,
      ),
      textTheme: TextTheme(
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelLarge: labelCaps,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
