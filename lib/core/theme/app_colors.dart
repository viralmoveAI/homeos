import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF6B9CFF);
  static const Color secondaryMint = Color(0xFF86E2C6);
  static const Color accentPurple = Color(0xFF9E7CFF);

  // Status Colors
  static const Color successGreen = Color(0xFF28C76F);
  static const Color warningOrange = Color(0xFFFF9F43);
  static const Color errorRed = Color(0xFFEA5455);
  static const Color infoBlue = Color(0xFF00CFE8);

  // Background and Surface
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  // Gradients
  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE6F0FF), // Light soft blue
      Color(0xFFE8F6F3), // Light mint
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF86E2C6), 
      Color(0xFF5ABEA0), 
    ],
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textHint = Color(0xFFA0AEC0);
}
