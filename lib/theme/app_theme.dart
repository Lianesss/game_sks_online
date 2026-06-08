import 'package:flutter/material.dart';

class AppTheme {
  // SKS Brand Colors
  static const Color primary = Color(0xFF8B1B1B);
  static const Color primaryLight = Color(0xFFB71C1C);
  static const Color accent = Color(0xFFE53935);
  static const Color accentLight = Color(0xFFFF6D6D);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB00020);
  static const Color cardBg = Color(0xFFFDFCFB);
  static const Color surface = Color(0xFFF9F5F3);
  static const Color bgLight = Color(0xFFFAF7F5);
  static const Color bgDark = Color(0xFF191720);
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF616161);
  static const Color border = Color(0xFFDDD6D0);

  // League colors
  static const Color bronze = Color(0xFFB76E2C);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFC107);
  static const Color platinum = Color(0xFFD7D7D7);
  static const Color diamond = Color(0xFF42A5F5);

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [accentLight, accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bgLight,
        canvasColor: bgLight,
        cardColor: cardBg,
        dividerColor: border,
        shadowColor: Colors.black.withValues(alpha: 0.14),
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: cardBg,
          error: error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgLight,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
          foregroundColor: textPrimary,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardBg,
          elevation: 12,
          selectedItemColor: accent,
          unselectedItemColor: Color(0xFF7A7A7A),
          selectedLabelStyle:
              TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          showUnselectedLabels: true,
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 6,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            elevation: 8,
            shadowColor: Colors.black26,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: const BorderSide(color: accent, width: 1.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: textSecondary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: textPrimary),
          displayMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          displaySmall: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
          headlineSmall: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.4),
          bodyMedium:
              TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
          labelLarge: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: primary, width: 1.8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(color: textSecondary),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
          contentTextStyle: const TextStyle(fontSize: 14, color: textSecondary),
        ),
      );
}
