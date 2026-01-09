import 'package:flutter/material.dart';

class AppTheme {
  // Primary Accent Color - Soft Blue/Periwinkle
  static const Color primary = Color(0xFF6C7BFF);
  static const Color primaryLight = Color(0xFF8F9BFF);
  static const Color primaryDark = Color(0xFF5A67D8);

  // Health / Success Color - Fresh Green
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFF7ED9A8);

  // Alert / Warning Color - Soft Red/Coral
  static const Color alert = Color(0xFFFF6B6B);
  static const Color alertDark = Color(0xFFFF7A7A);

  // Neutral / Card Colors
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardOffWhite = Color(0xFFF9FAFC);
  static const Color borderLight = Color(0xFFE6E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Background Gradient Colors
  static const Color backgroundLavender = Color(0xFFEEF0F8);
  static const Color backgroundLavenderLight = Color(0xFFF2F4FA);
  static const Color backgroundBeige = Color(0xFFFDF6F0);
  static const Color backgroundCream = Color(0xFFFAF8F5);

  // Pastel Gradient Colors
  static const Color pastelBlue = Color(0xFFACE6CF);
  static const Color pastelBlueMuted = Color(0xFFD4F0E0);
  static const Color lavenderMuted = Color(0xFFF5F3FB);

  // Legacy colors for compatibility
  static const Color primaryRed = alert;
  static const Color primaryWhite = cardWhite;
  static const Color textDark = textPrimary;

  static ThemeData theme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLavender,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: cardWhite,
      ),
    ),
  );
}
