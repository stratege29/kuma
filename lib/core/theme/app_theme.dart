import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs africaines
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBrown = Color(0xFF8B4513);
  
  static const Color backgroundLight = Color(0xFFFFFBF3);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color surfaceDark = Color(0xFF2D2C30);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.light,
        primary: primaryOrange,
        secondary: primaryGreen,
        tertiary: primaryBrown,
        background: backgroundLight,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
      ),
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      bottomSheetTheme: _bottomSheetTheme,
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.dark,
        primary: primaryOrange,
        secondary: primaryGreen,
        tertiary: primaryBrown,
        background: backgroundDark,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
      ),
      textTheme: _textTheme,
      appBarTheme: _appBarThemeDark,
      cardTheme: _cardThemeDark,
      elevatedButtonTheme: _elevatedButtonTheme,
      bottomSheetTheme: _bottomSheetThemeDark,
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      headlineLarge: GoogleFonts.comfortaa(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
      ),
      headlineMedium: GoogleFonts.comfortaa(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.comfortaa(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.comfortaa(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.4,
      ),
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: onSurfaceLight,
      titleTextStyle: GoogleFonts.comfortaa(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurfaceLight,
      ),
    );
  }

  static AppBarTheme get _appBarThemeDark {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: onSurfaceDark,
      titleTextStyle: GoogleFonts.comfortaa(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurfaceDark,
      ),
    );
  }

  static CardTheme get _cardTheme {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: surfaceLight,
    );
  }

  static CardTheme get _cardThemeDark {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: surfaceDark,
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: GoogleFonts.comfortaa(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static BottomSheetThemeData get _bottomSheetTheme {
    return BottomSheetThemeData(
      backgroundColor: surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
    );
  }

  static BottomSheetThemeData get _bottomSheetThemeDark {
    return BottomSheetThemeData(
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
    );
  }

  static PageTransitionsTheme get _pageTransitionsTheme {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    );
  }
}