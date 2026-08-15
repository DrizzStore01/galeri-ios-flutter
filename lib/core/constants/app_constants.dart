import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Galeri';
  static const String version = '1.0.0';

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSecondaryBackground = Color(0xFFF2F2F7); // systemGray6
  static const Color lightText = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF8E8E93); // systemGray
  static const Color lightAccent = Color(0xFF007AFF); // iOS Blue

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF000000); // systemBlack
  static const Color darkSecondaryBackground = Color(0xFF1C1C1E); // systemGray6 dark
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFF8E8E93); // systemGray
  static const Color darkAccent = Color(0xFF0A84FF); // iOS Blue dark

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Animation Durations
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 500);

  // Thumbnail Sizes
  static const double thumbnailSmall = 100.0;
  static const double thumbnailMedium = 200.0;
  static const double thumbnailLarge = 400.0;
}
