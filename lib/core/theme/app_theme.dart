import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB); // NexLink Blue
  static const Color secondaryColor = Color(0xFF22D3EE); // NexLink Cyan
  static const Color accentColor = Color(0xFF22D3EE);
  static const Color darkBgColor = Color(0xFF000000); // Pure Black
  static const Color surfaceColor = Color(0xFF0D0D0D); // Premium surface
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE17055);

  static const LinearGradient nexLinkGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: darkBgColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onPrimary: Colors.white,          
      onSecondary: Colors.white,
      error: errorColor,
      onSurface: textPrimary,
    ),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
    ).apply(
       bodyColor: textPrimary,
       displayColor: textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBgColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        side: const BorderSide(color: Colors.white10, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceColor,
      filled: true,
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
