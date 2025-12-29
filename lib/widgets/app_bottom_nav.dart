import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onFabPressed;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.cardOf(context);
    final unselected = AppColors.textSecondaryOf(context);

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: bg,
      elevation: 8,
      child: SizedBox(
        height: kBottomNavigationBarHeight + 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem(context, Icons.home_rounded, 'Home', 0, unselected)),
            Expanded(child: _buildNavItem(context, Icons.devices_rounded, 'Devices', 1, unselected)),
            Expanded(child: _buildNavItem(context, Icons.room_rounded, 'Rooms', 2, unselected)),
            Expanded(child: _buildNavItem(context, Icons.energy_savings_leaf_rounded, 'Energy', 3, unselected)),
            Expanded(child: _buildNavItem(context, Icons.settings_rounded, 'Settings', 4, unselected)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      IconData icon,
      String label,
      int index,
      Color unselected,
      ) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? AppColors.primary : unselected;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}