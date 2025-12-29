import 'package:flutter/material.dart';
import '../models/scene_item.dart';
import '../theme/app_colors.dart';

class SceneCard extends StatelessWidget {
  final SceneItem scene;
  final VoidCallback? onTap;

  const SceneCard({
    super.key,
    required this.scene,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.cardOf(context);
    final shadow = AppColors.shadowOf(context);
    final border = AppColors.borderSoftOf(context);
    final heading = AppColors.headingOf(context);
    final secondary = AppColors.textSecondaryOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: scene.isActive ? AppColors.primary : border,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(scene.icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: heading,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scene.subtitle,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: secondary),
          ],
        ),
      ),
    );
  }
}
