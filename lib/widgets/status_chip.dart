import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Status chip widget for dashboard (ONLINE, Active, etc.)
class StatusChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color? backgroundColor;
  final Widget? leadingIcon;

  const StatusChip({
    super.key,
    required this.label,
    required this.textColor,
    this.backgroundColor,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final shadow = AppColors.shadowOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primarySoftOf(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
