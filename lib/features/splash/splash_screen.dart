import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../auth/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final authController = Get.put(AuthController());
    authController.checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Icon Placeholder
            Icon(
              Icons.diamond_outlined,
              size: 80,
              color: AppColors.primary,
            ).animate().fade(duration: 600.ms).scale(delay: 200.ms),

            const SizedBox(height: 20),

            // App Name
            Text(
              'BLACK DIAMOND',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
