import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CA697);
  static const Color primaryDark = Color(0xFF4FA89B);
  static const Color primaryLight = Color(0xFF76D7C4);
  static const Color secondary = Color(0xFF7FAFA3);
  static const Color secondaryLight = Color(0xFF6FA89A);
  static const Color secondaryDark = Color(0xFF5A9A8D);

  // Gradient Colors (from image - teal to blue)
  static const Color gradientTeal = Color(0xFF4ECDC4); // Lighter teal at top
  static const Color gradientBlue = Color(0xFF2E86AB); // Deeper blue at bottom
  
  // Glass effect colors
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBackground = Color(0x40FFFFFF); // Semi-transparent white

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFE6F1EE);
  static const Color surface = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Medicine Status Colors
  static const Color taken = Color(0xFF4CAF50);
  static const Color skipped = Color(0xFFFF9800);
  static const Color pending = Color(0xFF9E9E9E);
}

