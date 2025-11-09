import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentraverse_frontend/core/theme/app_colors.dart';
import 'package:mentraverse_frontend/presentation/controllers/auth_controller.dart';
import 'package:mentraverse_frontend/presentation/widgets/custom_button.dart';
import 'package:mentraverse_frontend/presentation/widgets/custom_text_field.dart';
import 'package:mentraverse_frontend/presentation/widgets/social_auth_button.dart';

import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _ForgotPasswordSheet extends StatelessWidget {
  const _ForgotPasswordSheet({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Forgot your password?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the email associated with your account. We\'ll send you a link to reset your password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'name@example.com',
                filled: true,
                fillColor: isDark ? AppColors.darkBackground : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(email)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color:
                            isDark ? AppColors.darkTextSecondary : AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () {
                      final authController = Get.find<AuthController>();
                      return FilledButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () {
                                onSubmit();
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authController.isLoading.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Send Link',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  void _loginWithGoogle() {
    if (_authController.isLoading.value) return;
    _authController.signInWithGoogle();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _showForgotPasswordDialog() {
    if (_authController.isLoading.value) return;
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: _emailController.text.trim());

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: _ForgotPasswordSheet(
          formKey: formKey,
          controller: controller,
          onSubmit: () async {
            if (!formKey.currentState!.validate()) return;
            final success = await _authController.sendPasswordReset(
              controller.text,
              showFeedback: false,
            );
            if (success) {
              Get.back();
              Get.snackbar(
                'Reset email sent',
                'Check ${controller.text.trim()} for the reset link.',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      ),
      barrierDismissible: false,
    ).whenComplete(() {
      if (controller.hasListeners) controller.dispose();
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool useCompactLayout = constraints.maxWidth < 400;
          final double horizontalPadding = useCompactLayout ? 16 : 24;
          final double verticalPadding = useCompactLayout ? 24 : 32;
          final double panelPadding = useCompactLayout ? 20 : 32;
          final double logoRadius = useCompactLayout ? 28 : 32;
          final double panelRadius = useCompactLayout ? 20 : 24;
          final double headingFontSize = useCompactLayout ? 28 : 32;
          final double socialPadding = useCompactLayout ? 12 : 14;
          final double socialIconSize = useCompactLayout ? 20 : 24;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkBackground : null,
              gradient: isDarkMode
                  ? null
                  : LinearGradient(
                      colors: const [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: logoRadius,
                        backgroundColor: isDarkMode
                            ? AppColors.darkSurface
                            : Colors.white.withOpacity(0.7),
                        child: Icon(
                          Icons.school,
                          color: AppColors.primary,
                          size: logoRadius,
                        ),
                      ),
                      SizedBox(height: useCompactLayout ? 20 : 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: panelPadding,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.darkSurface
                                : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(panelRadius),
                            boxShadow: isDarkMode
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.12),
                                      blurRadius: 32,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Login',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        fontSize: headingFontSize,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: isDarkMode
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => Get.toNamed(AppRoutes.register),
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                CustomTextField(
                                  label: 'Email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.validateEmail,
                                  isRequired: true,
                                  hintText: 'Enter your email',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: isDarkMode
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                SizedBox(height: useCompactLayout ? 16 : 20),
                                CustomTextField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: Validators.validatePassword,
                                  isRequired: true,
                                  hintText: 'Enter your password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: isDarkMode
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDarkMode
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                    onPressed: _togglePasswordVisibility,
                                  ),
                                ),
                                SizedBox(height: useCompactLayout ? 12 : 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          activeColor: AppColors.primary,
                                        ),
                                        Text(
                                          'Remember me',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isDarkMode
                                                    ? AppColors.darkTextSecondary
                                                    : AppColors.lightTextSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: _showForgotPasswordDialog,
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: useCompactLayout ? 20 : 24),
                                Obx(
                                  () => CustomButton(
                                    text: 'Log In',
                                    onPressed: _login,
                                    isLoading: _authController.isLoading.value,
                                    height: useCompactLayout ? 48 : 52,
                                    borderRadius: useCompactLayout ? 10 : 12,
                                  ),
                                ),
                                SizedBox(height: useCompactLayout ? 20 : 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey[300],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'Or',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: isDarkMode
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.lightTextSecondary,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: useCompactLayout ? 20 : 24),
                                Obx(
                                  () => SocialAuthButton(
                                    leading: Image.asset(
                                      'assets/google.png',
                                      width: socialIconSize,
                                      height: socialIconSize,
                                      fit: BoxFit.contain,
                                    ),
                                    label: 'Continue with Google',
                                    onPressed: _authController.isLoading.value
                                        ? () {}
                                        : _loginWithGoogle,
                                    verticalPadding: socialPadding,
                                    iconSize: socialIconSize,
                                  ),
                                ),
                                SizedBox(height: useCompactLayout ? 10 : 12),
                            
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}