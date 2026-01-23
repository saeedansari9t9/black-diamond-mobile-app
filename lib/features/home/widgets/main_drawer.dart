import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/navigation_menu.dart';
import '../../auth/controllers/auth_controller.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject AuthController to handle logout
    final authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: AppColors.primary,
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond_outlined,
                    size: 48,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'BLACK DIAMOND',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                ...NavigationConfig.items.map((item) {
                  if (item.submenu != null && item.submenu!.isNotEmpty) {
                    return ExpansionTile(
                      leading: Icon(item.icon, color: Colors.white70),
                      title: Text(
                        item.label,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      iconColor: AppColors.secondary,
                      collapsedIconColor: Colors.white70,
                      children: item.submenu!.map((subItem) {
                        return ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 56,
                            right: 24,
                          ),
                          leading: Icon(
                            subItem.icon,
                            color: Colors.white54,
                            size: 20,
                          ),
                          title: Text(
                            subItem.label,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            if (subItem.route != null) {
                              // Close drawer then navigate
                              Get.back();
                              Get.toNamed(subItem.route!);
                            }
                          },
                        );
                      }).toList(),
                    );
                  } else {
                    return ListTile(
                      leading: Icon(item.icon, color: Colors.white70),
                      title: Text(
                        item.label,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        if (item.route == '/dashboard') {
                          Get.back();
                        } else if (item.route != null) {
                          Get.back();
                          Get.toNamed(item.route!);
                        }
                      },
                    );
                  }
                }),
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () {
                authController.logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
