import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const String fontFamily = 'SF Pro Text';
  static const String displayFontFamily = 'SF Pro Display';

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: displayFontFamily, fontSize: 34, fontWeight: FontWeight.bold, color: textColor), // largeTitle
      displayMedium: TextStyle(fontFamily: displayFontFamily, fontSize: 28, fontWeight: FontWeight.normal, color: textColor), // title1
      displaySmall: TextStyle(fontFamily: displayFontFamily, fontSize: 22, fontWeight: FontWeight.normal, color: textColor), // title2
      headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.normal, color: textColor), // title3
      headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 17, fontWeight: FontWeight.w600, color: textColor), // headline
      bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 17, fontWeight: FontWeight.normal, color: textColor), // body
      bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.normal, color: textColor), // callout
      bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.normal, color: textColor), // subhead
      labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.normal, color: textColor), // footnote
      labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.normal, color: textColor), // caption1
      labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.normal, color: textColor), // caption2
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppConstants.lightAccent,
      scaffoldBackgroundColor: AppConstants.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppConstants.lightAccent,
        secondary: AppConstants.lightAccent,
        surface: AppConstants.lightBackground,
        background: AppConstants.lightBackground,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConstants.lightText,
        onBackground: AppConstants.lightText,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(AppConstants.lightText),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppConstants.lightAccent),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppConstants.lightText,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xCCFFFFFF), // Translucent iOS style
        elevation: 0,
        selectedItemColor: AppConstants.lightAccent,
        unselectedItemColor: AppConstants.lightSecondaryText,
        type: BottomNavigationBarType.fixed,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppConstants.lightAccent,
        scaffoldBackgroundColor: AppConstants.lightBackground,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppConstants.darkAccent,
      scaffoldBackgroundColor: AppConstants.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.darkAccent,
        secondary: AppConstants.darkAccent,
        surface: AppConstants.darkSecondaryBackground,
        background: AppConstants.darkBackground,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConstants.darkText,
        onBackground: AppConstants.darkText,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(AppConstants.darkText),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppConstants.darkAccent),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppConstants.darkText,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xCC1C1C1E), // Translucent iOS style
        elevation: 0,
        selectedItemColor: AppConstants.darkAccent,
        unselectedItemColor: AppConstants.darkSecondaryText,
        type: BottomNavigationBarType.fixed,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppConstants.darkAccent,
        scaffoldBackgroundColor: AppConstants.darkBackground,
      ),
      useMaterial3: true,
    );
  }
}
