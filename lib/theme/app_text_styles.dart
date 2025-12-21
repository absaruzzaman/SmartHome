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

  /// Link text style - Forgot password / Sign up
  /// Size: 13-14, color: primary, semi-bold
  static TextStyle get link => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  /// Small link text style - for inline links
  static TextStyle get smallLink => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  // Dashboard styles
  /// Greeting title - "Good Evening"
  /// Size: 18-20, bold, heading
  static TextStyle get greetingTitle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.heading,
    fontFamily: 'Inter',
  );

  /// Greeting subtitle - "Welcome back, Sarah"
  /// Size: 12-13, regular, textSecondary
  static TextStyle get greetingSubtitle => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  /// Section title - "Overview", "Quick Actions"
  /// Size: 14-15, bold, heading
  static TextStyle get sectionTitle => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.heading,
    fontFamily: 'Inter',
  );

  /// Stat label - "Total Rooms"
  /// Size: 11-12, medium, textSecondary
  static TextStyle get statLabel => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  /// Stat value - "6"
  /// Size: 22-24, bold, heading
  static TextStyle get statValue => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.heading,
    fontFamily: 'Inter',
  );

  /// Device title - "Living Room Light"
  /// Size: 13-14, semi-bold, heading
  static TextStyle get deviceTitle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.heading,
    fontFamily: 'Inter',
  );

  /// Device subtitle - "Brightness: 75%"
  /// Size: 11-12, regular, textSecondary
  static TextStyle get deviceSubtitle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  /// Small link - "See All", "Manage"
  /// Size: 12-13, semi-bold, primary
  static TextStyle get smallActionLink => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );
}
