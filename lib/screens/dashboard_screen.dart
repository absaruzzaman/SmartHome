import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/status_chip.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/device_tile.dart';
import '../widgets/scene_card.dart';
import '../widgets/app_bottom_nav.dart';
import '../models/device_item.dart';
import 'rooms_screen.dart';

/// Dashboard/Home screen for the Smart Home application
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedBottomTab = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Device states for dashboard
  final List<Map<String, dynamic>> _dashboardDevices = [
    {
      'title': 'Living Room Light',
      'subtitle': 'Brightness: 75%',
      'icon': Icons.lightbulb_rounded,
      'color': AppColors.warning,
      'isOn': true,
    },
    {
      'title': 'Thermostat',
      'subtitle': 'Temperature: 22°C',
      'icon': Icons.thermostat_rounded,
      'color': AppColors.teal,
      'isOn': true,
    },
    {
      'title': 'Security Camera',
      'subtitle': 'Front Door',
      'icon': Icons.videocam_rounded,
      'color': AppColors.purple,
      'isOn': false,
    },
  ];

  // Scene items
  final List<SceneItem> _scenes = [
    SceneItem(
      title: 'Morning Routine',
      subtitle: '4 devices active',
      isActive: true,
      icon: Icons.wb_sunny_rounded,
    ),
    SceneItem(
      title: 'Night Mode',
      subtitle: '6 devices configured',
      isActive: false,
      icon: Icons.nightlight_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Setup entrance animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDevice(int index, bool value) {
    setState(() {
      _dashboardDevices[index]['isOn'] = value;
    });
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _navigateToRooms() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoomsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Row
                  _buildGreetingRow(),
                  const SizedBox(height: 16),

                  // Status Chips
                  _buildStatusChips(),
                  const SizedBox(height: 24),

                  // Overview Section
                  _buildOverviewSection(),
                  const SizedBox(height: 24),

                  // Quick Actions Section
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),

                  // Favorite Devices Section
                  _buildFavoriteDevicesSection(),
                  const SizedBox(height: 24),

                  // Active Scenes Section
                  _buildActiveScenesSection(),
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSnackbar('Add (mock)'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedBottomTab,
        onTabSelected: (index) {
          setState(() {
            _selectedBottomTab = index;
          });
          final tabs = ['Home', 'Devices', 'Scenes', 'Settings'];
          _showSnackbar('${tabs[index]} tab (mock)');
        },
        onFabPressed: () => _showSnackbar('Add (mock)'),
      ),
    );
  }

  Widget _buildGreetingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: AppTextStyles.greetingTitle,
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back!',
              style: AppTextStyles.greetingSubtitle,
            ),
          ],
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChips() {
    return Row(
      children: [
        StatusChip(
          label: 'ONLINE',
          textColor: AppColors.onlineGreen,
          leadingIcon: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.onlineGreen,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        StatusChip(
          label: '8 Active',
          textColor: AppColors.primary,
          leadingIcon: Icon(
            Icons.flash_on,
            size: 14,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              icon: Icons.apartment_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primarySoft,
              label: 'Total Rooms',
              value: '6',
            ),
            StatCard(
              icon: Icons.memory_rounded,
              iconColor: AppColors.purple,
              iconBgColor: AppColors.purple.withOpacity(0.15),
              label: 'Total Devices',
              value: '12',
            ),
            StatCard(
              icon: Icons.power_rounded,
              iconColor: AppColors.onlineGreen,
              iconBgColor: AppColors.onlineGreen.withOpacity(0.15),
              label: 'Online Devices',
              value: '8',
            ),
            StatCard(
              icon: Icons.bolt_rounded,
              iconColor: AppColors.warning,
              iconBgColor: AppColors.warning.withOpacity(0.15),
              label: 'Energy Today',
              value: '24 kWh',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: QuickActionTile(
                label: 'Add Scene',
                icon: Icons.add_circle_outline,
                isPrimary: true,
                onTap: () => _showSnackbar('Add Scene (mock)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionTile(
                label: 'Rooms',
                icon: Icons.meeting_room_rounded,
                onTap: _navigateToRooms,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionTile(
                label: 'Scenes',
                icon: Icons.auto_awesome_rounded,
                onTap: () => _showSnackbar('Scenes (mock)'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Favorite Devices',
              style: AppTextStyles.sectionTitle,
            ),
            TextButton(
              onPressed: () => _showSnackbar('See All (mock)'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: AppTextStyles.smallActionLink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dashboardDevices.length,
          itemBuilder: (context, index) {
            final device = _dashboardDevices[index];
            return DeviceTile(
              title: device['title'],
              subtitle: device['subtitle'],
              icon: device['icon'],
              color: device['color'],
              isOn: device['isOn'],
              onToggle: (value) => _toggleDevice(index, value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActiveScenesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Scenes',
              style: AppTextStyles.sectionTitle,
            ),
            TextButton(
              onPressed: () => _showSnackbar('Manage (mock)'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Manage',
                style: AppTextStyles.smallActionLink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(_scenes.map((scene) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SceneCard(
              scene: scene,
              onTap: () => _showSnackbar('${scene.title} tapped (mock)'),
            ),
          );
        }).toList()),
      ],
    );
  }
}
