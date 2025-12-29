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
      'color': Color(0xFF8B5CF6),
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

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.heading,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Energy Usage',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 20,
            color: AppColors.heading,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            color: AppColors.textSecondary,
            onPressed: () => _showSnackbar('Export report (mock)'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: AppColors.textSecondary,
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
                // Period selector
                _buildPeriodSelector(),
                const SizedBox(height: 20),

                // Total usage card
                _buildTotalUsageCard(currentData),
                const SizedBox(height: 20),

                // Stats grid
                _buildStatsGrid(currentData),
                const SizedBox(height: 24),

                // Chart placeholder
                _buildChartSection(),
                const SizedBox(height: 24),

                // Usage by room
                Text(
                  'Usage by Room',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 12),
                ..._buildRoomUsageList(),
                const SizedBox(height: 24),

                // Top consumers
                Text(
                  'Top Energy Consumers',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 12),
                ..._buildDeviceUsageList(),
                const SizedBox(height: 24),

                // Energy saving tips
                _buildEnergyTips(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 4, // Energy tab index
        onTabSelected: (index) {
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
              Navigator.pushReplacementNamed(context, '/settings');
              break;
            case 4:
              return; // Already on Energy
          }
        },
        onFabPressed: () {},
      ),

    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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

  Widget _buildTotalUsageCard(Map<String, dynamic> data) {
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
            color: AppColors.primary.withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha:0.9),
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
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
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

  Widget _buildStatsGrid(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Peak Time',
            data['peak'],
            Icons.schedule_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
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
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.deviceSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.deviceTitle.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Trend',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar('Mon', 0.7, AppColors.primary),
                  _buildChartBar('Tue', 0.85, AppColors.primary),
                  _buildChartBar('Wed', 0.6, AppColors.primary),
                  _buildChartBar('Thu', 0.9, AppColors.primary),
                  _buildChartBar('Fri', 0.75, AppColors.primary),
                  _buildChartBar('Sat', 0.5, AppColors.onlineGreen),
                  _buildChartBar('Sun', 0.45, AppColors.onlineGreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double heightFactor, Color color) {
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
                color: color.withValues(alpha: 0.2),
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
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoomUsageList() {
    return _roomUsage.map((room) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: room['color'].withValues(alpha :0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    room['icon'],
                    color: room['color'],
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
                        style: AppTextStyles.deviceTitle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: room['percentage'] / 100,
                          backgroundColor: AppColors.chipBg,
                          valueColor: AlwaysStoppedAnimation(room['color']),
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
                      style: AppTextStyles.deviceTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${room['percentage']}%',
                      style: AppTextStyles.deviceSubtitle.copyWith(
                        color: room['color'],
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

  List<Widget> _buildDeviceUsageList() {
    return _deviceUsage.map((device) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: device['color'].withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                device['icon'],
                color: device['color'],
                size: 24,
              ),
            ),
            title: Text(
              device['name'],
              style: AppTextStyles.deviceTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              device['room'],
              style: AppTextStyles.deviceSubtitle,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  device['usage'],
                  style: AppTextStyles.deviceTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  device['cost'],
                  style: AppTextStyles.deviceSubtitle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildEnergyTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: AppColors.onlineGreen.withValues(alpha: 0.1),
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
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Turn off devices when not in use'),
          _buildTipItem('Use energy-efficient LED bulbs'),
          _buildTipItem('Schedule high-power devices during off-peak hours'),
          _buildTipItem('Regular maintenance of AC and heating systems'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
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
              style: AppTextStyles.deviceSubtitle.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
