import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

/// Settings screen for user preferences and app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedBottomTab = 3; // Settings tab
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Settings states
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _deviceAlerts = true;
  bool _energyReports = true;
  bool _autoLock = true;
  bool _biometricAuth = false;
  String _temperatureUnit = 'Celsius';
  String _theme = 'Light';

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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await AuthService.instance.logout();
        await SessionManager.instance.clearToken();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        _showSnackbar('Logout failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 20,
            color: AppColors.heading,
          ),
        ),
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
                // Profile section
                _buildProfileCard(),
                const SizedBox(height: 24),

                // Notifications section
                _buildSectionTitle('Notifications'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'Push Notifications',
                    'Receive alerts on your device',
                    Icons.notifications_rounded,
                    _pushNotifications,
                        (value) => setState(() => _pushNotifications = value),
                  ),
                  _buildSwitchTile(
                    'Email Notifications',
                    'Get updates via email',
                    Icons.email_rounded,
                    _emailNotifications,
                        (value) => setState(() => _emailNotifications = value),
                  ),
                  _buildSwitchTile(
                    'Device Alerts',
                    'Notify when devices go offline',
                    Icons.warning_rounded,
                    _deviceAlerts,
                        (value) => setState(() => _deviceAlerts = value),
                  ),
                  _buildSwitchTile(
                    'Energy Reports',
                    'Weekly energy consumption reports',
                    Icons.eco_rounded,
                    _energyReports,
                        (value) => setState(() => _energyReports = value),
                  ),
                ]),
                const SizedBox(height: 24),

                // Security section
                _buildSectionTitle('Security'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'Auto Lock',
                    'Lock app when inactive',
                    Icons.lock_rounded,
                    _autoLock,
                        (value) => setState(() => _autoLock = value),
                  ),
                  _buildSwitchTile(
                    'Biometric Authentication',
                    'Use fingerprint or face ID',
                    Icons.fingerprint_rounded,
                    _biometricAuth,
                        (value) => setState(() => _biometricAuth = value),
                  ),
                  _buildNavigationTile(
                    'Change Password',
                    'Update your password',
                    Icons.key_rounded,
                        () => _showSnackbar('Change password (mock)'),
                  ),
                ]),
                const SizedBox(height: 24),

                // Preferences section
                _buildSectionTitle('Preferences'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildDropdownTile(
                    'Temperature Unit',
                    _temperatureUnit,
                    Icons.thermostat_rounded,
                    ['Celsius', 'Fahrenheit'],
                        (value) {
                      if (value != null) {
                        setState(() => _temperatureUnit = value);
                        _showSnackbar('Temperature unit changed to $value');
                      }
                    },
                  ),
                  _buildDropdownTile(
                    'Theme',
                    _theme,
                    Icons.palette_rounded,
                    ['Light', 'Dark', 'System'],
                        (value) {
                      if (value != null) {
                        setState(() => _theme = value);
                        _showSnackbar('Theme changed to $value (mock)');
                      }
                    },
                  ),
                  _buildNavigationTile(
                    'Language',
                    'English (US)',
                    Icons.language_rounded,
                        () => _showSnackbar('Language settings (mock)'),
                  ),
                ]),
                const SizedBox(height: 24),

                // About section
                _buildSectionTitle('About'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildNavigationTile(
                    'Help & Support',
                    'Get help with the app',
                    Icons.help_rounded,
                        () => _showSnackbar('Help & Support (mock)'),
                  ),
                  _buildNavigationTile(
                    'Privacy Policy',
                    'Review our privacy policy',
                    Icons.privacy_tip_rounded,
                        () => _showSnackbar('Privacy Policy (mock)'),
                  ),
                  _buildNavigationTile(
                    'Terms of Service',
                    'Read terms and conditions',
                    Icons.description_rounded,
                        () => _showSnackbar('Terms of Service (mock)'),
                  ),
                  _buildInfoTile(
                    'App Version',
                    '1.0.0',
                    Icons.info_rounded,
                  ),
                ]),
                const SizedBox(height: 24),

                // Logout button
                _buildLogoutButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSnackbar('Quick settings (mock)'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.tune_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedBottomTab,
        onTabSelected: (index) {
          if (index != _selectedBottomTab) {
            setState(() {
              _selectedBottomTab = index;
            });
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/scenes');
            } else {
              final tabs = ['Home', 'Devices', 'Scenes', 'Settings'];
              _showSnackbar('${tabs[index]} tab');
            }
          }
        },
        onFabPressed: () => _showSnackbar('Quick settings (mock)'),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DA3FF), Color(0xFF2B7FDB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sarah Johnson',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'sarah.johnson@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            color: Colors.white,
            onPressed: () => _showSnackbar('Edit profile (mock)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle,
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.deviceSubtitle,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavigationTile(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.deviceSubtitle,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
      String title,
      String value,
      IconData icon,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        value,
        style: AppTextStyles.deviceSubtitle.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
      String title,
      String value,
      IconData icon,
      List<String> options,
      ValueChanged<String?> onChanged,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}