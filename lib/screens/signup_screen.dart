import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../utils/form_validators.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

/// Signup screen for the Smart Home application (theme-sensitive)
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.authClient});

  final AuthClient? authClient;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AuthClient _authClient;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authClient = widget.authClient ?? AuthService.instance;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) => FormValidators.validateName(v);
  String? _validateEmail(String? v) => FormValidators.validateEmail(v);
  String? _validatePassword(String? v) => FormValidators.validatePassword(v);

  String? _validateConfirmPassword(String? v) =>
      FormValidators.validateConfirmPassword(v, _passwordController.text);

  Future<void> _handleSignUp() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authClient.register(
        name: _nameController.text.trim(),
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

      await SessionManager.instance.saveUserName(name);
      // If you have saveUserEmail in SessionManager, keep it; otherwise remove it.
      // await SessionManager.instance.saveUserEmail(_emailController.text.trim().toLowerCase());

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Unable to create account. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBackToLogin() {
    if (_isLoading) return;
    Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Theme-sensitive surfaces
    final bg = cs.surface; // overall page bg
    final cardBg = cs.surfaceContainerHighest; // card background
    final shadowColor = Colors.black.withOpacity(isDark ? 0.25 : 0.12);

    // Theme-sensitive text/icon
    final textSecondary = cs.onSurface.withOpacity(0.65);

    return Scaffold(
      backgroundColor: bg,
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
                    // Main Card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.outlineVariant.withOpacity(isDark ? 0.35 : 0.55),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo Icon
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
                                child: const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: Icon(
                                        Icons.wifi,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Title
                            Text(
                              'Create Account',
                              style: AppTextStyles.titleOf(context).copyWith(
                                color: cs.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              'Sign up to get started',
                              style: AppTextStyles.subtitleOf(context).copyWith(
                                color: textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Name Field
                            AppTextField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              controller: _nameController,
                              validator: _validateName,
                              keyboardType: TextInputType.name,
                              suffixIcon: Icon(
                                Icons.person_outline,
                                color: textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email Field
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

                            // Password Field
                            AppTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              validator: _validatePassword,
                              obscureText: true,
                              canToggleObscure: true,
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password Field
                            AppTextField(
                              label: 'Confirm Password',
                              hint: 'Re-enter your password',
                              controller: _confirmPasswordController,
                              validator: _validateConfirmPassword,
                              obscureText: true,
                              canToggleObscure: true,
                            ),
                            const SizedBox(height: 24),

                            // Sign Up Button
                            PrimaryButton(
                              text: _isLoading ? 'Creating...' : 'Sign Up',
                                onPressed: () {
                                  if (_isLoading) return;
                                  _handleSignUp();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Back to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: AppTextStyles.smallLinkOf(context).copyWith(
                            color: textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _handleBackToLogin,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.primary,
                          ),
                          child: Text(
                            'Sign in',
                            style: AppTextStyles.linkOf(context).copyWith(
                              color: AppColors.primary,
                            ),
                          ),
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
