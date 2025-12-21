import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography tokens for the Smart Home application
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // Login screen styles
  /// Title style - "Smart Home"
  /// Size: 26-28, bold, color: heading
  static TextStyle get title => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.heading,
        fontFamily: 'Inter',
      );

  /// Subtitle style - "Control everything, effortlessly"
  /// Size: 13-14, regular, color: textSecondary
  static TextStyle get subtitle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  /// Small link text style - for inline links
  static TextStyle get smallLink => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  /// Link text style - Forgot password / Sign up
  /// Size: 13-14, color: primary, semi-bold
  static TextStyle get link => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  /// Field label style - "Email" / "Password"
  /// Size: 13, semi-bold, color: heading
  static TextStyle get fieldLabel => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.heading,
    fontFamily: 'Inter',
  );

  /// Button text style
  /// Size: 15-16, semi-bold, white
  static TextStyle get button => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Inter',
  );

}
