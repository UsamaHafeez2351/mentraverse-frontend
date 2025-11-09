import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mentraverse_frontend/core/theme/app_colors.dart';
import 'package:mentraverse_frontend/presentation/controllers/auth_controller.dart';
import 'package:mentraverse_frontend/presentation/widgets/custom_button.dart';
import 'package:mentraverse_frontend/presentation/widgets/custom_text_field.dart';

import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();

  String? _selectedRole;
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 16, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: isDarkMode ? AppColors.darkSurface : Colors.white,
                  onSurface: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      Get.snackbar('Role required', 'Please choose how you want to register.');
      return;
    }

    final profile = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'birthDate': _birthDateController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _selectedRole,
    };

    final success = await _authController.registerWithProfile(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      profile: profile,
    );

    if (success) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool useCompactLayout = constraints.maxWidth < 400;
          final double horizontalPadding = useCompactLayout ? 16 : 24;
          final double verticalPadding = useCompactLayout ? 16 : 24;
          final double panelPadding = useCompactLayout ? 20 : 32;
          final double panelRadius = useCompactLayout ? 20 : 24;
          final double headingFontSize = useCompactLayout ? 30 : 34;

          return Container(
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: isDarkMode ? AppColors.darkTextPrimary : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: panelPadding,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkSurface : AppColors.lightBackground,
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
                                'Register',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontSize: headingFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: isDarkMode
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => Get.offAllNamed(AppRoutes.login),
                                    child: Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final double columnWidth = innerConstraints.maxWidth;
                                  final double fieldWidth = useCompactLayout
                                      ? columnWidth
                                      : (columnWidth - 16) / 2;
                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      SizedBox(
                                        width: fieldWidth,
                                        child: CustomTextField(
                                          label: 'First Name',
                                          controller: _firstNameController,
                                          validator: Validators.validateName,
                                          hintText: 'Enter your first name',
                                          isRequired: true,
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: CustomTextField(
                                          label: 'Last Name',
                                          controller: _lastNameController,
                                          validator: Validators.validateName,
                                          hintText: 'Enter your last name',
                                          isRequired: true,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                                hintText: 'name@example.com',
                                isRequired: true,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: InputDecoration(
                                  labelText: 'Role',
                                  labelStyle: Theme.of(context).textTheme.labelMedium,
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? AppColors.darkSurface
                                      : AppColors.lightSurface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDarkMode
                                          ? AppColors.darkTextSecondary
                                          : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDarkMode
                                          ? AppColors.darkTextSecondary
                                          : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'student',
                                    child: Text('Student'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'teacher',
                                    child: Text('Teacher'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Please choose a role' : null,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Birth date',
                                controller: _birthDateController,
                                hintText: 'DD/MM/YYYY',
                                readOnly: true,
                                onTap: _pickBirthDate,
                                isRequired: true,
                                suffixIcon: const Icon(Icons.calendar_today_outlined),
                                validator: (_) => _birthDateController.text.isEmpty ? 'Select your birth date' : null,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                hintText: '+92 300 1234567',
                                isRequired: true,
                                prefixIcon: const Icon(Icons.phone_outlined),
                                validator: Validators.validatePhone,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Set Password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: Validators.validatePassword,
                                isRequired: true,
                                hintText: 'Enter password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                isRequired: true,
                                hintText: 'Re-enter password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: _toggleConfirmPasswordVisibility,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Obx(
                                () => CustomButton(
                                  text: 'Register',
                                  onPressed: _handleRegister,
                                  isLoading: _authController.isLoading.value,
                                  height: useCompactLayout ? 48 : 52,
                                  borderRadius: useCompactLayout ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
