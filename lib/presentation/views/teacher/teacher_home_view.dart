import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentraverse_frontend/core/theme/app_colors.dart';
import 'package:mentraverse_frontend/presentation/controllers/auth_controller.dart';
import 'package:mentraverse_frontend/presentation/widgets/custom_button.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Welcome Teacher'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome Teacher!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Logout',
              onPressed: authController.logout,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
