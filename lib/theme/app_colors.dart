import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF4DA3FF);
  static const Color primarySoft = Color(0xFFEAF4FF);

  // Light defaults
  static const Color bg = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  static const Color heading = Color(0xFF1F2A44);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color borderSoft = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x14000000);

  // Status colors
  static const Color onlineGreen = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color teal = Color(0xFF14B8A6);
  static const Color purple = Color(0xFF8B5CF6);

  // Badges
  static const Color onlineBg = Color(0xFFE7F7ED);
  static const Color onlineText = Color(0xFF16A34A);

  static const Color offlineBg = Color(0xFFF3F4F6);
  static const Color offlineText = Color(0xFF6B7280);

  static const Color waitingBg = Color(0xFFFFF7ED);
  static const Color waitingText = Color(0xFFF59E0B);

  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color errorText = Color(0xFFDC2626);

  // Fields
  static const Color fieldBg = Color(0xFFF9FAFB);
  static const Color fieldBorder = Color(0xFFE5E7EB);

  // ------------------------------------------------------------
  // ✅ Theme-aware (context) colors
  // ------------------------------------------------------------

  static Color bgOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0B1220) : bg;
  }

  static Color cardOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF111B2E) : card;
  }

  static Color headingOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE5E7EB) : heading;
  }

  static Color textSecondaryOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9CA3AF) : textSecondary;
  }

  static Color borderSoftOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white.withOpacity(0.10) : borderSoft;
  }

  static Color shadowOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.08);
  }

  static Color primarySoftOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF16334D) : primarySoft;
  }

  static Color onlineBgOf(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0F2A1D) : onlineBg;
  }

  static Color onlineTextOf(BuildContext context) {
    // keep green in both themes (simple)
    return onlineText;
  }

  static Color errorTextOf(BuildContext context) => Theme.of(context).colorScheme.error;

  // Icon helpers
  static IconData iconFromCodePoint(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  static int codePointFromIcon(IconData icon) => icon.codePoint;
}
