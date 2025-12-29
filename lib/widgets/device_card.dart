import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/device_item.dart';
import 'status_badge.dart';

/// Device card widget for room devices grid
class DeviceCard extends StatelessWidget {
  final DeviceItem device;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.cardOf(context);
    final shadow = AppColors.shadowOf(context);
    final primarySoft = AppColors.primarySoftOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.borderSoftOf(context),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon and badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      device.icon,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: device.status),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                device.name,
                style: AppTextStyles.deviceTitleOf(context).copyWith(
                  color: AppColors.headingOf(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              Text(
                device.value,
                style: AppTextStyles.deviceSubtitleOf(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
