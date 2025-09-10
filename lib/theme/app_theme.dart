import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF594A9C); // #594A9C
  static const Color inputBackground = Color(0xFFE8E8F5); // #E8E8F5
  static const Color primaryBackground = Color(0xFFFFFFFF); // #FFFFFF
  static const Color textColor = Colors.black; // default text
  static const Color textButtonActive = primaryColor;
  static const Color textButtonDisabledBg = inputBackground;
  static const Color textButtonBg = primaryColor;
  static const Color textButtonText = Colors.white;

  // Font Sizes
  static const double heading1 = 24.0;
  static const double heading2 = 20.0;
  static const double heading3 = 18.0;
  static const double body = 16.0;
  static const double small = 14.0;
  static const double extraSmall = 12.0;

  // Font Weights
  static const FontWeight bold = FontWeight.bold;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight regular = FontWeight.normal;

  // ThemeData
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: primaryBackground,
    canvasColor: primaryBackground,
    fontFamily: 'Roboto',

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: heading2,
        fontWeight: bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // TextTheme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: AppTheme.heading1,
        fontWeight: AppTheme.bold,
        color: AppTheme.textColor,
      ),
      displayMedium: TextStyle(
        fontSize: AppTheme.heading2,
        fontWeight: AppTheme.bold,
        color: AppTheme.textColor,
      ),
      displaySmall: TextStyle(
        fontSize: AppTheme.heading3,
        fontWeight: AppTheme.semiBold,
        color: AppTheme.textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: AppTheme.body,
        fontWeight: AppTheme.regular,
        color: AppTheme.textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTheme.small,
        fontWeight: AppTheme.regular,
        color: AppTheme.textColor,
      ),
      bodySmall: TextStyle(
        fontSize: AppTheme.extraSmall,
        fontWeight: AppTheme.regular,
        color: AppTheme.textColor,
      ),
      titleLarge: TextStyle(
        fontSize: AppTheme.body,
        fontWeight: AppTheme.bold,
        color: AppTheme.textButtonText,
      ),
    ),

    // ElevatedButton Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return textButtonDisabledBg;
          }
          if (states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered)) {
            return primaryColor.withOpacity(0.8);
          }
          return textButtonBg;
        }),
        foregroundColor: WidgetStateProperty.all(textButtonText),
        textStyle: WidgetStateProperty.all(TextStyle(fontWeight: bold)),
      ),
    ),

    // TextButton Theme
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return textColor.withAlpha(150);
          }
          if (states.contains(WidgetState.selected) ||
              states.contains(WidgetState.pressed)) {
            return textButtonActive;
          }
          return textColor;
        }),
        textStyle: WidgetStateProperty.all(
          TextStyle(fontWeight: bold, fontSize: heading3),
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackground,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: TextStyle(color: Colors.white, fontWeight: bold),
      actionTextColor: Colors.white,
    ),

    // Switch / Toggle Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(primaryColor),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? primaryColor.withOpacity(0.5)
            : Colors.grey.shade300,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: primaryBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black12,
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(primaryColor),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(primaryColor),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryBackground,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: TextStyle(fontWeight: bold),
      unselectedLabelStyle: TextStyle(fontWeight: regular),
    ),
  );
}
