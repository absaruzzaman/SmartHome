import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/status_chip.dart';
import '../widgets/stat_card.dart';
import '../widgets/device_tile.dart';
import '../widgets/app_bottom_nav.dart';
import 'rooms_screen.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

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

  String _userName = 'User';

  // We'll resolve colors inside build() using context-aware colors
  final List<Map<String, dynamic>> _dashboardDevices = [
    {
      'title': 'Living Room Light',
      'subtitle': 'Brightness: 75%',
      'icon': Icons.lightbulb_rounded,
      'colorKey': 'warn',
      'isOn': true,
    },
    {
      'title': 'Thermostat',
      'subtitle': 'Temperature: 22°C',
      'icon': Icons.thermostat_rounded,
      'colorKey': 'teal',
      'isOn': true,
    },
    {
      'title': 'Security Camera',
      'subtitle': 'Front Door',
      'icon': Icons.videocam_rounded,
      'colorKey': 'purple',
      'isOn': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final name = await SessionManager.instance.getUserName();
    if (!mounted) return;

    setState(() {
      final clean = (name ?? '').trim();
      _userName = clean.isEmpty ? 'User' : clean;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    await SessionManager.instance.clearSession();


    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _toggleDevice(int index, bool value) {
    setState(() {
      _dashboardDevices[index]['isOn'] = value;
    });
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
      MaterialPageRoute(builder: (_) => const RoomsScreen()),
    );
  }

  // Theme-safe “accent” colors (no dependency on AppColors.warning/purple/teal)
  Color _accentFor(BuildContext context, String key) {
    final scheme = Theme.of(context).colorScheme;
    switch (key) {
      case 'warn':
        return scheme.tertiary; // works fine as "warning-ish"
      case 'purple':
        return scheme.secondary;
      case 'teal':
        return scheme.primary;
      default:
        return scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final heading = AppColors.headingOf(context);
    final subText = AppColors.textSecondaryOf(context);

    // Use your theme-aware status colors (from AppColors)
    final onlineText = AppColors.onlineTextOf(context);

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
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
                  _buildGreetingRow(context, heading, subText),
                  const SizedBox(height: 16),

                  _buildStatusChips(context, onlineText),
                  const SizedBox(height: 24),

                  _buildOverviewSection(context),
                  const SizedBox(height: 24),

                  _buildFavoriteDevicesSection(context),
                  const SizedBox(height: 24),
                ],
              ),
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
        onFabPressed: () {
          // optional
        },
      ),
    );
  }

  Widget _buildGreetingRow(BuildContext context, Color heading, Color subText) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.greetingTitleOf(context), // make sure AppTextStyles uses ...Of(context)
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back, $_userName',
                style: AppTextStyles.greetingSubtitleOf(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          color: subText,
          tooltip: 'Logout',
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

  Widget _buildStatusChips(BuildContext context, Color onlineText) {
    return Row(
      children: [
        StatusChip(
          label: 'ONLINE',
          textColor: onlineText,
          leadingIcon: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: onlineText,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        StatusChip(
          label: '8 Active',
          textColor: AppColors.primary,
          leadingIcon: const Icon(
            Icons.flash_on,
            size: 14,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppTextStyles.sectionTitleOf(context)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            StatCard(
              icon: Icons.apartment_rounded,
              iconColor: scheme.primary,
              iconBgColor: AppColors.primarySoftOf(context),
              label: 'Total Rooms',
              value: '6',
            ),
            StatCard(
              icon: Icons.memory_rounded,
              iconColor: scheme.secondary,
              iconBgColor: scheme.secondary.withOpacity(0.15),
              label: 'Total Devices',
              value: '12',
            ),
            StatCard(
              icon: Icons.power_rounded,
              iconColor: AppColors.onlineTextOf(context),
              iconBgColor: AppColors.onlineTextOf(context).withOpacity(0.15),
              label: 'Online Devices',
              value: '8',
            ),
            StatCard(
              icon: Icons.bolt_rounded,
              iconColor: scheme.tertiary,
              iconBgColor: scheme.tertiary.withOpacity(0.15),
              label: 'Energy Today',
              value: '24 kWh',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteDevicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Favorite Devices', style: AppTextStyles.sectionTitleOf(context)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/devices'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('See All', style: AppTextStyles.smallActionLinkOf(context)),
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
            final accent = _accentFor(context, device['colorKey'] as String);

            return DeviceTile(
              title: device['title'],
              subtitle: device['subtitle'],
              icon: device['icon'],
              color: accent,
              isOn: device['isOn'],
              onToggle: (value) => _toggleDevice(index, value),
            );
          },
        ),
      ],
    );
  }
}
