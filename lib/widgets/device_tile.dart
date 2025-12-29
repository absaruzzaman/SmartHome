import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Device tile widget for favorite devices section
class DeviceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isOn;
  final ValueChanged<bool> onToggle;

  const DeviceTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.cardOf(context);
    final shadow = AppColors.shadowOf(context);
    final heading = AppColors.headingOf(context);
    final secondary = AppColors.textSecondaryOf(context);
    final border = AppColors.borderSoftOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.deviceTitleOf(context).copyWith(
                    color: heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.deviceSubtitleOf(context).copyWith(
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch.adaptive(
            value: isOn,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
