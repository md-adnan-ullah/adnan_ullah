import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light theme matching Kreston-style design: warm beige background,
/// maroon/burgundy accent, clean typography, solid components (no glass).
class PortfolioTheme {
  PortfolioTheme._();

  // Light background – warm beige / off-white
  static const Color background = Color(0xFFEDEAE5);
  static const Color surface = Color(0xFFF5F3F0);
  static const Color card = Color(0xFFFFFFFF);

  // Accent – deep maroon / burgundy
  static const Color accentPrimary = Color(0xFF5B2C3B);
  static const Color accentSecondary = Color(0xFF6B3A4A);

  // Text on light background
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF6B7280);

  // Dividers and borders
  static const Color divider = Color(0xFFE0DDD8);
  static const Color border = Color(0xFFE5E2DD);

  // Status (keep bKash for payment button)
  static const Color bkash = Color(0xFFE2136E);

  // Hero / section background (same as page for consistency)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDEAE5), Color(0xFFE9E5E0)],
  );

  static ThemeData light() {
    final baseText = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: surface,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          color: accentPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: baseText.displayMedium?.copyWith(
          color: accentPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: textSecondary,
          height: 1.6,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: baseText.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardColor: card,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
          textStyle: baseText.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: accentPrimary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      dividerColor: divider,
    );
  }
}
