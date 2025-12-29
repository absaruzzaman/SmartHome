import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/device_item.dart';

/// Status badge widget for device cards
class StatusBadge extends StatelessWidget {
  final DeviceStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: config.textColor,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return _StatusConfig(
          label: 'ONLINE',
          backgroundColor: AppColors.onlineBg,
          textColor: AppColors.onlineText,
        );
      case DeviceStatus.offline:
        return _StatusConfig(
          label: 'OFFLINE',
          backgroundColor: AppColors.offlineBg,
          textColor: AppColors.offlineText,
        );
      case DeviceStatus.waiting:
        return _StatusConfig(
          label: 'WAITING',
          backgroundColor: AppColors.waitingBg,
          textColor: AppColors.waitingText,
        );
      case DeviceStatus.error:
        return _StatusConfig(
          label: 'ERROR',
          backgroundColor: AppColors.errorBg,
          textColor: AppColors.errorText,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
