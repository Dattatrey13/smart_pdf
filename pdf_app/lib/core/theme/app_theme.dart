import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDeep = Color(0xFF4A42D4);
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentGlow = Color(0xFF00D4FF);
  static const Color surface = Color(0xFF0F0F1A);
  static const Color surfaceCard = Color(0xFF1A1A2E);
  static const Color surfaceElevated = Color(0xFF16213E);
  static const Color onSurface = Color(0xFFF0F0FF);
  static const Color onSurfaceMuted = Color(0xFF8080A8);
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF5F7E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [surface, Color(0xFF0D0D1F), surfaceElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surfaceCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        error: error,
      ),
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      // tabBarTheme: const TabBarThemeData(
      //   labelColor: primary,
      //   unselectedLabelColor: onSurfaceMuted,
      //   indicatorColor: primary,
      //   labelStyle: TextStyle(
      //     fontFamily: 'Outfit',
      //     fontWeight: FontWeight.w600,
      //     fontSize: 13,
      //     letterSpacing: 0.5,
      //   ),
      //   unselectedLabelStyle: TextStyle(
      //     fontFamily: 'Outfit',
      //     fontWeight: FontWeight.w400,
      //     fontSize: 13,
      //   ),
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        hintStyle: const TextStyle(color: onSurfaceMuted, fontFamily: 'Outfit'),
        labelStyle: const TextStyle(color: onSurfaceMuted, fontFamily: 'Outfit'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      // cardTheme: CardThemeData(
      //   color: surfaceCard,
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //     side: const BorderSide(color: Color(0xFF2A2A4A), width: 1),
      //   ),
      // ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A4A),
        thickness: 1,
      ),
    );
  }
}