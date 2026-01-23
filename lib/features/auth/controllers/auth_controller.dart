import 'package:get/get.dart';
import '../../home/screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final success = await _authService.login(email, password);

      if (success) {
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

  void logout() {
    // Clear token logic if implemented in service
    Get.offAllNamed('/'); // Navigate to login/splash
  }
}
