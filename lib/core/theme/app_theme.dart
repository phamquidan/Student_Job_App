import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'stitch_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: StitchColors.primary,
      onPrimary: StitchColors.onPrimary,
      primaryContainer: StitchColors.primaryContainer,
      onPrimaryContainer: StitchColors.onSurface,
      secondary: StitchColors.secondary,
      onSecondary: StitchColors.onSecondary,
      secondaryContainer: StitchColors.secondaryContainer,
      onSecondaryContainer: StitchColors.onSecondaryContainer,
      tertiary: StitchColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: StitchColors.tertiaryContainer,
      onTertiaryContainer: StitchColors.onSurface,
      error: const Color(0xFFB31B25),
      onError: Colors.white,
      surface: StitchColors.surface,
      onSurface: StitchColors.onSurface,
      surfaceContainerHighest: StitchColors.surfaceContainerHigh,
      surfaceContainerHigh: StitchColors.surfaceContainerHigh,
      surfaceContainer: StitchColors.surfaceContainer,
      surfaceContainerLow: StitchColors.surfaceContainerLow,
      surfaceContainerLowest: StitchColors.surfaceContainerLowest,
      outline: StitchColors.outline,
      outlineVariant: StitchColors.outlineVariant,
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: StitchColors.onSurface,
        height: 1.1,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: StitchColors.onSurface,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: StitchColors.onSurface,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: StitchColors.onSurface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: StitchColors.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: StitchColors.onSurface,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: StitchColors.onSurfaceVariant,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: StitchColors.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: StitchColors.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: StitchColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: StitchColors.onSurface,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: StitchColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: StitchColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: StitchColors.surfaceContainerLowest.withOpacity(0.92),
        indicatorColor: StitchColors.primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StitchColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StitchColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.inter(color: StitchColors.outline.withOpacity(0.65)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
