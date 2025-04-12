import 'package:flutter/material.dart';

class AppTheme {
  // Color constants that meet WCAG accessibility guidelines
  static const Color _primaryLight = Color(0xFFE65100); // Darker orange for better contrast
  static const Color _primaryDark = Color(0xFFFFB74D);  // Lighter orange for dark mode

  static const Color _textOnLightBackground = Color(0xFF212121); // Near black
  static const Color _textOnDarkBackground = Color(0xFFF5F5F5);  // Near white

  static const Color _lightBackground = Color(0xFFFAFAFA);
  static const Color _darkBackground = Color(0xFF121212);

  // Light theme that meets accessibility standards
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme with proper contrast ratios
      colorScheme: ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.white,
        secondary: _primaryLight.withOpacity(0.8),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: _textOnLightBackground,
        background: _lightBackground,
        onBackground: _textOnLightBackground,
        error: Colors.red.shade700, // Darker red for better contrast
        onError: Colors.white,
      ),

      // Scaffold and card backgrounds
      scaffoldBackgroundColor: _lightBackground,
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // App bar with consistent styling
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Bottom navigation with accessible colors
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _primaryLight,
        unselectedItemColor: Colors.grey.shade600, // Darker for better contrast
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Typography that scales properly
      textTheme: TextTheme(
        // Headings
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: _primaryLight,
          letterSpacing: 0.15,
        ),
        // Subheadings
        titleMedium: TextStyle(
          fontSize: 18.0,
          fontStyle: FontStyle.italic,
          color: _textOnLightBackground.withOpacity(0.8),
          letterSpacing: 0.15,
        ),
        // Body text
        bodyLarge: TextStyle(
          fontSize: 16.0,
          color: _textOnLightBackground,
          height: 1.5, // Better line height for readability
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          color: _textOnLightBackground,
          height: 1.5,
        ),
      ),

      // List tiles with proper spacing
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        textColor: _textOnLightBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryLight, width: 2),
        ),
      ),
    );
  }

  // Dark theme that meets accessibility standards
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme with proper contrast ratios for dark mode
      colorScheme: ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: Colors.black,
        secondary: _primaryDark.withOpacity(0.8),
        onSecondary: Colors.black,
        surface: Color(0xFF1E1E1E),
        onSurface: _textOnDarkBackground,
        background: _darkBackground,
        onBackground: _textOnDarkBackground,
        error: Colors.red.shade300, // Lighter red for dark mode
        onError: Colors.black,
      ),

      // Scaffold and card backgrounds
      scaffoldBackgroundColor: _darkBackground,
      cardTheme: CardTheme(
        color: Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // App bar with consistent styling
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.black, // Dark text on light background for contrast
        elevation: 0,
      ),

      // Bottom navigation with accessible colors
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: _primaryDark,
        unselectedItemColor: Colors.grey.shade400, // Lighter for contrast on dark
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Typography that scales properly
      textTheme: TextTheme(
        // Headings
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: _primaryDark,
          letterSpacing: 0.15,
        ),
        // Subheadings
        titleMedium: TextStyle(
          fontSize: 18.0,
          fontStyle: FontStyle.italic,
          color: _textOnDarkBackground.withOpacity(0.9), // Higher opacity for better contrast
          letterSpacing: 0.15,
        ),
        // Body text
        bodyLarge: TextStyle(
          fontSize: 16.0,
          color: _textOnDarkBackground,
          height: 1.5, // Better line height for readability
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          color: _textOnDarkBackground,
          height: 1.5,
        ),
      ),

      // List tiles with proper spacing
      listTileTheme: ListTileThemeData(
        tileColor: Color(0xFF2C2C2C),
        textColor: _textOnDarkBackground,
        iconColor: _primaryDark,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF323232),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryDark, width: 2),
        ),
      ),
    );
  }
}