import 'package:flutter/material.dart';

/// App color tokens for the Smart Home application
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  /// Soft Sky Blue - Primary brand color
  static const Color primary = Color(0xFF4DA3FF);

  /// Background color - Pure white
  static const Color bg = Color(0xFFFFFFFF);

  /// Shadow color with opacity
  static Color get shadow => Colors.black.withOpacity(0.08);

  /// Dark Navy - Heading text color
  static const Color heading = Color(0xFF1F2A44);

  /// Neutral Gray - Secondary text color
  static const Color textSecondary = Color(0xFF6B7280);

  /// Field background color - White
  static const Color fieldBg = Color(0xFFFFFFFF);

  /// Field border (alias for consistency)
  static const Color fieldBorder = Color(0xFFE5E7EB);

}
