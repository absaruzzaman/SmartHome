import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../utils/form_validators.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

/// Login screen for the Smart Home application
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthClient _authClient;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _authClient = AuthService.instance;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) => FormValidators.validateEmail(value);

  String? _validatePassword(String? value) =>
      FormValidators.validatePassword(value);

  Future<void> _handleSignIn() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authClient.login(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );

      final dynamic user = await _authClient.fetchCurrentUser();


      String name = '';
      if (user is Map) {
        final data = user['data'];
        final u = user['user'];

        name = (user['name'] ??
            (data is Map ? data['name'] : null) ??
            (u is Map ? u['name'] : null) ??
            '')
            .toString()
            .trim();
      }

      await SessionManager.instance.saveUserName(name.isEmpty ? 'User' : name);
      await SessionManager.instance.saveUserEmail(_emailController.text.trim().toLowerCase());

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot password not available!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _showError(String message) {
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
    final heading = AppColors.headingOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    final titleStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'Inter',
      color: heading,
    );

    final subtitleStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      fontFamily: 'Inter',
      color: textSecondary,
    );

    final linkStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
      color: AppColors.primary,
    );

    final smallLinkStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      fontFamily: 'Inter',
      color: textSecondary,
    );

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      decoration: BoxDecoration(
                        color: AppColors.cardOf(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowOf(context),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: const [
                                    Icon(Icons.home_rounded,
                                        color: Colors.white, size: 32),
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: Icon(Icons.wifi,
                                          color: Colors.white, size: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Smart Home',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Control everything, effortlessly',
                              style: subtitleStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            AppTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              controller: _emailController,
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              suffixIcon: Icon(
                                Icons.mail_outline,
                                color: textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 20),

                            AppTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              validator: _validatePassword,
                              obscureText: true,
                              canToggleObscure: true,
                            ),
                            const SizedBox(height: 24),

                            PrimaryButton(
                              text: _isLoading ? 'Signing in...' : 'Sign In',
                              onPressed: () {
                                if (_isLoading) return;
                                _handleSignIn();
                              },
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: TextButton(
                                onPressed:
                                _isLoading ? null : _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: linkStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: smallLinkStyle),
                        TextButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Sign up', style: linkStyle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
