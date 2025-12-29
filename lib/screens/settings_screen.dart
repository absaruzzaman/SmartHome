import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../services/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedBottomTab = 4;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _deviceAlerts = true;
  bool _energyReports = true;
  bool _autoLock = true;
  bool _biometricAuth = false;

  String _temperatureUnit = 'Celsius';
  String _theme = 'Light';

  String _userName = 'User';
  String _userEmail = 'Not set';

  @override
  void initState() {
    super.initState();

    _theme = ThemeController.instance.modeLabel;

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

    // ✅ load username/email after init
    _loadProfile();
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

  // ✅ Real profile data from SessionManager
  Future<void> _loadProfile() async {
    final name = await SessionManager.instance.getUserName();
    final email = await SessionManager.instance.getUserEmail();

    if (!mounted) return;
    setState(() {
      final cleanName = (name ?? '').trim();
      final cleanEmail = (email ?? '').trim();

      _userName = cleanName.isEmpty ? 'User' : cleanName;
      _userEmail = cleanEmail.isEmpty ? 'Not set' : cleanEmail;
    });
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

        // ✅ clear everything (token + name + email)
        // If you don't have clearSession(), replace with clearToken()+remove name/email.
        await SessionManager.instance.clearSession();

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
        }
      } catch (e) {
        _showSnackbar('Logout failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bgOf(context);
    final heading = AppColors.headingOf(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: AppTextStyles.sectionTitleOf(context).copyWith(
            fontSize: 20,
            color: heading,
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
                _buildProfileCard(context),
                const SizedBox(height: 24),

                _buildSectionTitle('Notifications'),
                const SizedBox(height: 12),
                _buildSettingsCard(context, [
                  _buildSwitchTile(
                    context,
                    'Push Notifications',
                    'Receive alerts on your device',
                    Icons.notifications_rounded,
                    _pushNotifications,
                        (value) => setState(() => _pushNotifications = value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Email Notifications',
                    'Get updates via email',
                    Icons.email_rounded,
                    _emailNotifications,
                        (value) => setState(() => _emailNotifications = value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Device Alerts',
                    'Notify when devices go offline',
                    Icons.warning_rounded,
                    _deviceAlerts,
                        (value) => setState(() => _deviceAlerts = value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Energy Reports',
                    'Weekly energy consumption reports',
                    Icons.eco_rounded,
                    _energyReports,
                        (value) => setState(() => _energyReports = value),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Security'),
                const SizedBox(height: 12),
                _buildSettingsCard(context, [
                  _buildSwitchTile(
                    context,
                    'Auto Lock',
                    'Lock app when inactive',
                    Icons.lock_rounded,
                    _autoLock,
                        (value) => setState(() => _autoLock = value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Biometric Authentication',
                    'Use fingerprint or face ID',
                    Icons.fingerprint_rounded,
                    _biometricAuth,
                        (value) => setState(() => _biometricAuth = value),
                  ),
                  _buildNavigationTile(
                    context,
                    'Change Password',
                    'Update your password',
                    Icons.key_rounded,
                        () => _showSnackbar('Change password'),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Preferences'),
                const SizedBox(height: 12),
                _buildSettingsCard(context, [
                  _buildDropdownTile(
                    context,
                    'Temperature Unit',
                    _temperatureUnit,
                    Icons.thermostat_rounded,
                    ['Celsius', 'Fahrenheit'],
                        (value) {
                      if (value == null) return;
                      setState(() => _temperatureUnit = value);
                      _showSnackbar('Temperature unit changed to $value');
                    },
                  ),
                  _buildDropdownTile(
                    context,
                    'Theme',
                    _theme,
                    Icons.palette_rounded,
                    ['Light', 'Dark', 'System'],
                        (value) async {
                      if (value == null) return;
                      setState(() => _theme = value);
                      await ThemeController.instance.setTheme(value);
                      _showSnackbar('Theme changed to $value');
                    },
                  ),
                  _buildNavigationTile(
                    context,
                    'Language',
                    'English (US)',
                    Icons.language_rounded,
                        () => _showSnackbar('Language settings'),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('About'),
                const SizedBox(height: 12),
                _buildSettingsCard(context, [
                  _buildNavigationTile(
                    context,
                    'Help & Support',
                    'Get help with the app',
                    Icons.help_rounded,
                        () => _showSnackbar('Help & Support'),
                  ),
                  _buildNavigationTile(
                    context,
                    'Privacy Policy',
                    'Review our privacy policy',
                    Icons.privacy_tip_rounded,
                        () => _showSnackbar('Privacy Policy'),
                  ),
                  _buildNavigationTile(
                    context,
                    'Terms of Service',
                    'Read terms and conditions',
                    Icons.description_rounded,
                        () => _showSnackbar('Terms of Service'),
                  ),
                  _buildInfoTile(context, 'App Version', '1.0.0', Icons.info_rounded),
                ]),
                const SizedBox(height: 24),

                _buildLogoutButton(context),
                const SizedBox(height: 100),
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

  // ---------------- UI Helpers ----------------

  Widget _buildProfileCard(BuildContext context) {
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
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.white,
            tooltip: 'Refresh profile',
            onPressed: _loadProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.sectionTitleOf(context));
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
      BuildContext context,
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
          color: AppColors.primarySoftOf(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitleOf(context).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.headingOf(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.deviceSubtitleOf(context).copyWith(
          color: AppColors.textSecondaryOf(context),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavigationTile(
      BuildContext context,
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
          color: AppColors.primarySoftOf(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitleOf(context).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.headingOf(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.deviceSubtitleOf(context).copyWith(
          color: AppColors.textSecondaryOf(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondaryOf(context),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
      BuildContext context,
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
          color: AppColors.primarySoftOf(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitleOf(context).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.headingOf(context),
        ),
      ),
      trailing: Text(
        value,
        style: AppTextStyles.deviceSubtitleOf(context).copyWith(
          color: AppColors.textSecondaryOf(context),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
      BuildContext context,
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
          color: AppColors.primarySoftOf(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.deviceTitleOf(context).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.headingOf(context),
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: AppColors.cardOf(context),
        items: options
            .map((option) => DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.12),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
