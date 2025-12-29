import 'package:flutter/material.dart';
import 'package:smart_home/screens/edit_profile_screen.dart';
import 'package:smart_home/screens/settings_screen.dart';
import 'package:smart_home/services/auth_service.dart';
import 'package:smart_home/services/session_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  String _userEmail = 'loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final sessionName = await SessionManager.instance.getUserName();
    if (mounted) {
      setState(() {
        _userName = sessionName ?? 'User';
      });
    }

    try {
      final user = await AuthService.instance.fetchCurrentUser();
      if (!mounted) return;

      final name = (user['name'] ?? user['data']?['name'] ?? user['user']?['name'] ?? _userName).toString().trim();
      final email = (user['email'] ?? user['data']?['email'] ?? user['user']?['email'] ?? '').toString().trim();

      setState(() {
        _userName = name.isEmpty ? 'User' : name;
        _userEmail = email;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _userEmail = 'Could not load email';
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    await SessionManager.instance.clearToken();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          // Profile Avatar & Name
          Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _userName,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  _userEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Smart Home Stats Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Home Overview',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.lightbulb, 'Devices', '12'),
                    _buildStatItem(Icons.thermostat, 'Temperature', '22°C'),
                    _buildStatItem(Icons.bolt, 'Energy', '120 kWh'),
                  ],
                ),
              ],
            ), 
          ),

          const SizedBox(height: 30),

          // Profile Options
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.deepPurple),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final updatedName = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(currentName: _userName),
                      ),
                    );

                    if (updatedName != null && mounted) {
                      setState(() => _userName = updatedName);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurple),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.deepPurple),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for stats items
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }
}
