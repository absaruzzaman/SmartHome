import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bottom_nav.dart';

/// Energy usage screen for monitoring power consumption
class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedBottomTab = 3;

  String _selectedPeriod = 'Today';
  final List<String> _periods = ['Today', 'Week', 'Month', 'Year'];

  final Map<String, Map<String, dynamic>> _energyData = {
    'Today': {
      'total': '24.5 kWh',
      'cost': '\$3.68',
      'peak': '18:00 - 20:00',
      'average': '1.02 kW',
      'savings': '+12%',
    },
    'Week': {
      'total': '168.2 kWh',
      'cost': '\$25.23',
      'peak': 'Monday 18:00',
      'average': '1.00 kW',
      'savings': '+8%',
    },
    'Month': {
      'total': '712.5 kWh',
      'cost': '\$106.88',
      'peak': 'Week 3',
      'average': '0.98 kW',
      'savings': '+15%',
    },
    'Year': {
      'total': '8,550 kWh',
      'cost': '\$1,282.50',
      'peak': 'July',
      'average': '0.98 kW',
      'savings': '+18%',
    },
  };

  final List<Map<String, dynamic>> _roomUsage = [
    {
      'name': 'Living Room',
      'usage': '6.8 kWh',
      'percentage': 28,
      'color': const Color(0xFF4DA3FF),
      'icon': Icons.living_rounded,
    },
    {
      'name': 'Kitchen',
      'usage': '5.2 kWh',
      'percentage': 21,
      'color': const Color(0xFFF59E0B),
      'icon': Icons.kitchen_rounded,
    },
    {
      'name': 'Master Bedroom',
      'usage': '4.5 kWh',
      'percentage': 18,
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.bed_rounded,
    },
    {
      'name': 'Home Office',
      'usage': '3.9 kWh',
      'percentage': 16,
      'color': const Color(0xFF14B8A6),
      'icon': Icons.computer_rounded,
    },
    {
      'name': 'Bathroom',
      'usage': '2.1 kWh',
      'percentage': 9,
      'color': const Color(0xFF22C55E),
      'icon': Icons.bathroom_rounded,
    },
    {
      'name': 'Other',
      'usage': '2.0 kWh',
      'percentage': 8,
      'color': const Color(0xFF9CA3AF),
      'icon': Icons.more_horiz_rounded,
    },
  ];

  final List<Map<String, dynamic>> _deviceUsage = [
    {
      'name': 'Air Conditioning',
      'room': 'Living Room',
      'usage': '4.2 kWh',
      'cost': '\$0.63',
      'icon': Icons.ac_unit_rounded,
      'color': const Color(0xFF4DA3FF),
    },
    {
      'name': 'Water Heater',
      'room': 'Bathroom',
      'usage': '3.8 kWh',
      'cost': '\$0.57',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFFF59E0B),
    },
    {
      'name': 'Refrigerator',
      'room': 'Kitchen',
      'usage': '2.4 kWh',
      'cost': '\$0.36',
      'icon': Icons.kitchen_rounded,
      'color': const Color(0xFF14B8A6),
    },
    {
      'name': 'Computer',
      'room': 'Home Office',
      'usage': '1.9 kWh',
      'cost': '\$0.29',
      'icon': Icons.computer_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'TV',
      'room': 'Living Room',
      'usage': '1.5 kWh',
      'cost': '\$0.23',
      'icon': Icons.tv_rounded,
      'color': const Color(0xFF22C55E),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _energyData[_selectedPeriod]!;

    final bg = AppColors.bgOf(context);
    final heading = AppColors.headingOf(context);
    final secondary = AppColors.textSecondaryOf(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: heading,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Energy Usage',
          style: AppTextStyles.sectionTitleOf(context).copyWith(
            fontSize: 20,
            color: heading,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            color: secondary,
            onPressed: () => _showSnackbar('Export report (mock)'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: secondary,
            onPressed: () => _showSnackbar('More options (mock)'),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(context),
                const SizedBox(height: 20),

                _buildTotalUsageCard(context, currentData),
                const SizedBox(height: 20),

                _buildStatsGrid(context, currentData),
                const SizedBox(height: 24),

                _buildChartSection(context),
                const SizedBox(height: 24),

                Text(
                  'Usage by Room',
                  style: AppTextStyles.sectionTitleOf(context),
                ),
                const SizedBox(height: 12),
                ..._buildRoomUsageList(context),
                const SizedBox(height: 24),

                Text(
                  'Top Energy Consumers',
                  style: AppTextStyles.sectionTitleOf(context),
                ),
                const SizedBox(height: 12),
                ..._buildDeviceUsageList(context),
                const SizedBox(height: 24),

                _buildEnergyTips(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedBottomTab,
        onTabSelected: (index) {
          if (index == _selectedBottomTab) return;
          setState(() => _selectedBottomTab = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/devices');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/rooms');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/energy');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
        onFabPressed: () {},
      ),
    );
  }

  // ----------- Widgets -----------

  Widget _buildPeriodSelector(BuildContext context) {
    final card = AppColors.cardOf(context);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderSoftOf(context), width: 1),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedPeriod = period),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondaryOf(context),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalUsageCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DA3FF), Color(0xFF2B7FDB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Usage',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['total'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cost: ${data['cost']}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data['savings']} vs last period',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Peak Time',
            data['peak'],
            Icons.schedule_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Average',
            data['average'],
            Icons.speed_rounded,
            AppColors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderSoftOf(context), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.deviceSubtitleOf(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.deviceTitleOf(context).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderSoftOf(context), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Trend',
              style: AppTextStyles.sectionTitleOf(context).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar(context, 'Mon', 0.7, AppColors.primary),
                  _buildChartBar(context, 'Tue', 0.85, AppColors.primary),
                  _buildChartBar(context, 'Wed', 0.6, AppColors.primary),
                  _buildChartBar(context, 'Thu', 0.9, AppColors.primary),
                  _buildChartBar(context, 'Fri', 0.75, AppColors.primary),
                  _buildChartBar(context, 'Sat', 0.5, AppColors.onlineGreen),
                  _buildChartBar(context, 'Sun', 0.45, AppColors.onlineGreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(
      BuildContext context, String label, double heightFactor, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: 100 * heightFactor,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                border: Border.all(color: color, width: 2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryOf(context),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoomUsageList(BuildContext context) {
    return _roomUsage.map((room) {
      final Color roomColor = room['color'] as Color;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardOf(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowOf(context),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.borderSoftOf(context), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: roomColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    room['icon'],
                    color: roomColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name'],
                        style: AppTextStyles.deviceTitleOf(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (room['percentage'] as int) / 100,
                          backgroundColor: AppColors.primarySoftOf(context),
                          valueColor: AlwaysStoppedAnimation(roomColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      room['usage'],
                      style: AppTextStyles.deviceTitleOf(context).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${room['percentage']}%',
                      style: AppTextStyles.deviceSubtitleOf(context).copyWith(
                        color: roomColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildDeviceUsageList(BuildContext context) {
    return _deviceUsage.map((device) {
      final Color deviceColor = device['color'] as Color;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardOf(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowOf(context),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.borderSoftOf(context), width: 1),
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: deviceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                device['icon'],
                color: deviceColor,
                size: 24,
              ),
            ),
            title: Text(
              device['name'],
              style: AppTextStyles.deviceTitleOf(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              device['room'],
              style: AppTextStyles.deviceSubtitleOf(context),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  device['usage'],
                  style: AppTextStyles.deviceTitleOf(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  device['cost'],
                  style: AppTextStyles.deviceSubtitleOf(context).copyWith(
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildEnergyTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderSoftOf(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.onlineGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.onlineGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Energy Saving Tips',
                style: AppTextStyles.sectionTitleOf(context).copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(context, 'Turn off devices when not in use'),
          _buildTipItem(context, 'Use energy-efficient LED bulbs'),
          _buildTipItem(context, 'Schedule high-power devices during off-peak hours'),
          _buildTipItem(context, 'Regular maintenance of AC and heating systems'),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.onlineGreen,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.deviceSubtitleOf(context).copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
