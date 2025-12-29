import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_home/screens/rooms_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'theme/app_colors.dart';
import 'services/auth_service.dart';
import 'services/session_manager.dart';

void main() {
  // Set preferred orientations and system UI overlay style
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for status bar
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        // Additional theme customizations
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Start with login screen
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/rooms': (context) => const RoomsScreen(),
      },
    );
  }
}
