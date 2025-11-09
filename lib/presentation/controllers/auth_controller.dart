import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mentraverse_frontend/routes/app_routes.dart';
import 'package:mentraverse_frontend/presentation/widgets/role_selector_sheet.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final Future<void> _googleInitFuture;

  final isLoading = false.obs;
  static const _roleKey = 'user_role';

  @override
  void onInit() {
    super.onInit();
    _ensureStorageInitialized();
    _googleInitFuture = _googleSignIn.initialize();
  }

  Future<void> _ensureStorageInitialized() async {
    if (!GetStorage().hasData(_roleKey)) {
      await _storage.write(_roleKey, null);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final role = await _fetchUserRole(credential.user);
      await _storage.write(_roleKey, role);

      Get.snackbar(
        'Success',
        'Logged in as ${credential.user?.email ?? ''}',
        snackPosition: SnackPosition.BOTTOM,
      );

      _navigateToRoleScreen(role);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login failed',
        e.message ?? 'Invalid credentials',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      await _googleInitFuture;

      final account = await _googleSignIn.authenticate();

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Unable to sign in with Google user.',
        );
      }

      String? role = await _fetchUserRole(user);
      if (role == null) {
        final selectedRole = await _promptRoleSelection();
        if (selectedRole == null) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          Get.snackbar(
            'Role required',
            'Please choose a role to continue.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final profile = _buildProfileFromGoogle(user, selectedRole);
        await _firestore.collection('users').doc(user.uid).set(profile);
        await _replicateToMySql(firebaseUid: user.uid, profile: profile);
        role = selectedRole;
      }

      await _storage.write(_roleKey, role);

      Get.snackbar(
        'Success',
        'Logged in as ${user.email ?? ''}',
        snackPosition: SnackPosition.BOTTOM,
      );

      _navigateToRoleScreen(role);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Google sign-in failed',
        e.message ?? 'Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerWithProfile({
    required String email,
    required String password,
    required Map<String, dynamic> profile,
  }) async {
    try {
      isLoading.value = true;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(profile);
      await _storage.write(_roleKey, profile['role']);

      await _replicateToMySql(
        firebaseUid: credential.user!.uid,
        profile: profile,
      );

      Get.snackbar(
        'Success',
        'Account created for ${credential.user?.email ?? ''}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Registration failed',
        e.message ?? 'Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _storage.remove(_roleKey);
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> _fetchUserRole(User? user) async {
    if (user == null) return null;
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data()?['role'] as String?;
  }

  void _navigateToRoleScreen(String? role) {
    if (role == 'teacher') {
      Get.offAllNamed(AppRoutes.teacherHome);
    } else {
      Get.offAllNamed(AppRoutes.studentHome);
    }
  }

  bool get isLoggedIn => _auth.currentUser != null;
  String? get currentUserEmail => _auth.currentUser?.email;
  String? get cachedRole => _storage.read<String?>(_roleKey);

  Future<bool> sendPasswordReset(
    String email, {
    bool showFeedback = true,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      Get.snackbar(
        'Email required',
        'Please enter the email associated with your account.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: trimmed);
      if (showFeedback) {
        Get.snackbar(
          'Reset email sent',
          'Check $trimmed for instructions to reset your password.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Reset failed',
        e.message ?? 'Could not send reset email. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _promptRoleSelection() async {
    return showRoleSelectorSheet();
  }

  Map<String, dynamic> _buildProfileFromGoogle(User user, String role) {
    return {
      'firstName': user.displayName?.split(' ').first ?? '',
      'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'birthDate': '',
      'role': role,
    };
  }

  Future<void> _replicateToMySql({
    required String firebaseUid,
    required Map<String, dynamic> profile,
  }) async {
    final apiUrl = const String.fromEnvironment(
      'MENTRAVERSE_API_BASE',
      defaultValue: 'http://localhost:3000',
    );

    final uri = Uri.parse('$apiUrl/api/auth/register');

    final payload = {
      'firebaseUid': firebaseUid,
      'firstName': profile['firstName'],
      'lastName': profile['lastName'],
      'email': profile['email'],
      'phone': profile['phone'],
      'birthDate': profile['birthDate'],
      'role': profile['role'],
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 400) {
        Get.snackbar(
          'Sync warning',
          'MySQL replication failed (${response.statusCode}).',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Sync warning',
        'MySQL replication error. Check your network connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}