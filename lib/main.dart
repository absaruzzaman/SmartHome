import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_home/screens/energy_screen.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/all_devices_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/rooms_screen.dart';

import 'theme/app_colors.dart';
import 'services/auth_service.dart';
import 'services/session_manager.dart';
import 'services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load saved theme BEFORE app starts
  await ThemeController.instance.load();

  // System UI (you can later make this dynamic for dark mode)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatefulWidget {
  const SmartHomeApp({super.key});

  @override
  State<SmartHomeApp> createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  late Future<bool> _sessionCheckFuture;

  @override
  void initState() {
    super.initState();
    _sessionCheckFuture = _checkExistingSession();
  }

  Future<bool> _checkExistingSession() async {
    final token = await SessionManager.instance.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final user = await AuthService.instance.fetchCurrentUser();
      final name = (user['name'] ??
          user['data']?['name'] ??
          user['user']?['name'] ??
          '')
          .toString()
          .trim();

      await SessionManager.instance.saveUserName(name.isEmpty ? 'User' : name);
      return true;
    } catch (_) {
      await SessionManager.instance.clearToken();
      return false;
    }
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (_, __) {
        return MaterialApp(
          title: 'Smart Home',
          debugShowCheckedModeBanner: false,

          // THEME SWITCH HERE
          themeMode: ThemeController.instance.mode,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),

          // keep your routes
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/rooms': (context) => const RoomsScreen(),
            '/devices': (context) => const AllDevicesScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/energy': (context) => const EnergyScreen(),
          },

          // real startup: go dashboard if session valid else login
          home: FutureBuilder<bool>(
            future: _sessionCheckFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final ok = snapshot.data == true;
              return ok ? const DashboardScreen() : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}