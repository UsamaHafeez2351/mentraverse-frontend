import 'package:get/get.dart';
import 'package:mentraverse_frontend/presentation/controllers/auth_controller.dart';
import 'package:mentraverse_frontend/presentation/views/auth/login_view.dart';
import 'package:mentraverse_frontend/presentation/views/auth/register_view.dart';
import 'package:mentraverse_frontend/presentation/views/student/student_home_view.dart';
import 'package:mentraverse_frontend/presentation/views/teacher/teacher_home_view.dart';

import 'app_routes.dart';

/// Configuration for all GetX pages and their bindings.
class AppPages {
  AppPages._();

  static String get initial {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    final authController = Get.find<AuthController>();
    if (authController.isLoggedIn) {
      final role = authController.cachedRole ?? 'student';
      return role == 'teacher' ? AppRoutes.teacherHome : AppRoutes.studentHome;
    }
    return AppRoutes.login;
  }

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.studentHome,
      page: () => const StudentHomeView(),
    ),
    GetPage(
      name: AppRoutes.teacherHome,
      page: () => const TeacherHomeView(),
    ),
  ];
}
