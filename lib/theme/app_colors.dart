import 'package:flutter/material.dart';

/// App color tokens for the Smart Home application
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  /// Soft Sky Blue - Primary brand color
  static const Color primary = Color(0xFF4DA3FF);

  /// Light Blue accent - Soft primary variant
  static const Color primarySoft = Color(0xFFEAF4FF);

  /// Background color - Pure white
  static const Color bg = Color(0xFFFFFFFF);

  /// Dark Navy - Heading text color
  static const Color heading = Color(0xFF1F2A44);

  /// Neutral Gray - Secondary text color
  static const Color textSecondary = Color(0xFF6B7280);

  /// Card background color - White
  static const Color card = Color(0xFFFFFFFF);

  /// Field background color - White
  static const Color fieldBg = Color(0xFFFFFFFF);

  /// Very subtle border color
  static const Color borderSoft = Color(0xFFE5E7EB);

  /// Field border (alias for consistency)
  static const Color fieldBorder = Color(0xFFE5E7EB);

  /// Light gray chip background
  static const Color chipBg = Color(0xFFF3F4F6);

  /// Shadow color with opacity
  static Color get shadow => Colors.black.withOpacity(0.08);

  // Status colors
  /// Online/success green
  static const Color onlineGreen = Color(0xFF22C55E);

  /// Warning/alert orange
  static const Color warning = Color(0xFFF59E0B);

  /// Purple accent
  static const Color purple = Color(0xFF8B5CF6);

  /// Teal accent
  static const Color teal = Color(0xFF14B8A6);

  // Device status badge colors
  /// Online badge background
  static const Color onlineBg = Color(0xFFDCFCE7);

  /// Online badge text
  static const Color onlineText = Color(0xFF16A34A);

  /// Offline badge background
  static const Color offlineBg = Color(0xFFF3F4F6);

  /// Offline badge text
  static const Color offlineText = Color(0xFF6B7280);

  /// Waiting badge background
  static const Color waitingBg = Color(0xFFFEF9C3);

  /// Waiting badge text
  static const Color waitingText = Color(0xFFCA8A04);

  /// Error badge background
  static const Color errorBg = Color(0xFFFEE2E2);

  /// Error badge text
  static const Color errorText = Color(0xFFDC2626);
}
