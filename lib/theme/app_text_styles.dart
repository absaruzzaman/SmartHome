import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ---------- Auth / Headings ----------
  static TextStyle titleOf(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    fontFamily: 'Inter',
    color: AppColors.headingOf(context),
  );

  static TextStyle subtitleOf(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.textSecondaryOf(context),
    height: 1.4,
  );

  static TextStyle fieldLabelOf(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColors.headingOf(context),
  );

  static TextStyle buttonOf(BuildContext context) => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    letterSpacing: 0.2,
    color: Colors.white,
  );

  static TextStyle linkOf(BuildContext context) => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: AppColors.primary,
  );

  static TextStyle smallLinkOf(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.textSecondaryOf(context),
  );

  // ---------- Dashboard greeting ----------
  static TextStyle greetingTitleOf(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    fontFamily: 'Inter',
    color: AppColors.headingOf(context),
  );

  static TextStyle greetingSubtitleOf(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.textSecondaryOf(context),
    height: 1.4,
  );

  static TextStyle smallActionLinkOf(BuildContext context) => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: AppColors.primary,
  );

  // ---------- Sections ----------
  static TextStyle sectionTitleOf(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: AppColors.headingOf(context),
  );

  // ---------- Devices ----------
  static TextStyle deviceTitleOf(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColors.headingOf(context),
  );

  static TextStyle deviceSubtitleOf(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.textSecondaryOf(context),
  );

  static TextStyle bodyOf(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.headingOf(context),
  );

  // ---------- Stats ----------
  static TextStyle statLabelOf(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColors.textSecondaryOf(context),
  );

  static TextStyle statValueOf(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    fontFamily: 'Inter',
    color: AppColors.headingOf(context),
  );
}
