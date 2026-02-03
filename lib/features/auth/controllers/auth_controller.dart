import 'package:get/get.dart';
import '../../home/screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial user info
    userName.value = _authService.userName;
    userEmail.value = _authService.userEmail;
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final success = await _authService.login(email, password);

      if (success) {
        // Update user info
        userName.value = _authService.userName;
        userEmail.value = _authService.userEmail;

        Get.snackbar(
          'Success',
          'Login Successful!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar(
          'Error',
          'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    final token = await _authService.getToken();
    if (token != null) {
      // Refresh user profile in background
      _authService.getMe().then((_) {
        userName.value = _authService.userName;
        userEmail.value = _authService.userEmail;
      });
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(
        () => const LoginScreen(),
      ); // Or named route '/login' if I register it. But LoginScreen is not registered as named route in GetPages yet? It is not.
      // Wait, LoginScreen is NOT in getPages in main.dart.
      // I should registered check main.dart again.
      // main.dart doesn't have LoginScreen route in getPages.
      // I should can add it potentially, or just use class. Class is fine.
    }
  }

  void logout() async {
    // Clear storage
    await _authService.logout();

    // Clear local state
    userName.value = '';
    userEmail.value = '';

    // Navigate to Login Screen
    // using Get.offAll to remove all previous routes
    Get.offAll(() => const LoginScreen());
  }
}
