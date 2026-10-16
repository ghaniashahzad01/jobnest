
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0B0B12);
  static const Color surface = Color(0xFF151520);
  static const Color primary = Color(0xFF9B6DFF);
  static const Color secondary = Color(0xFF6265F1);
  static const Color accent = Color(0xFF36D6C3);
  static const Color mutedText = Color(0xFF9292A7);

  static const Color lightBackground = Color(0xFFF7F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF7950D9);
  static const Color lightBorder = Color(0xFFE5E3EF);
  static const Color lightText = Color(0xFF242236);

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      backgroundColor: background,
      surfaceColor: surface,
      primaryColor: primary,
      textColor: Colors.white,
      mutedColor: mutedText,
      borderColor: const Color(0xFF292938),
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      backgroundColor: lightBackground,
      surfaceColor: lightSurface,
      primaryColor: lightPrimary,
      textColor: lightText,
      mutedColor: const Color(0xFF77758A),
      borderColor: lightBorder,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color primaryColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderColor,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      surface: surfaceColor,
    ).copyWith(
      primary: primaryColor,
      secondary: accent,
      surface: surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hintStyle: TextStyle(color: mutedColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      dividerColor: borderColor,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white70 : mutedColor,
      ),
    );
  }
}
