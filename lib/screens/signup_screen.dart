import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../utils/form_validators.dart';

/// Signup screen for the Smart Home application
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      begin: const Offset(0, 0.1),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    return FormValidators.validateName(value);
  }

  String? _validateEmail(String? value) {
    return FormValidators.validateEmail(value);
  }

  String? _validatePassword(String? value) {
    return FormValidators.validatePassword(value);
  }

  String? _validateConfirmPassword(String? value) {
    return FormValidators.validateConfirmPassword(value, _passwordController.text);
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully (mock)'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 500),
        ),
      );
      debugPrint('Sign up successful (mock)');
      
      // Navigate to dashboard after successful sign up
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      });
    }
  }

  void _handleBackToLogin() {
    Navigator.of(context).pop();
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
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
                            // Logo Icon
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
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
                              style: AppTextStyles.title,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              'Sign up to get started',
                              style: AppTextStyles.subtitle,
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
                              suffixIcon: const Icon(
                                Icons.person_outline,
                                color: AppColors.textSecondary,
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
                              suffixIcon: const Icon(
                                Icons.mail_outline,
                                color: AppColors.textSecondary,
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
                              text: 'Sign Up',
                              onPressed: _handleSignUp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Back to Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: AppTextStyles.smallLink,
                          ),
                          TextButton(
                            onPressed: _handleBackToLogin,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign in',
                              style: AppTextStyles.link,
                            ),
                          ),
                        ],
                      ),
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
