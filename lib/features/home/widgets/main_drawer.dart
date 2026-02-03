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

    // "side bar ka color meri theme ka use kro" - Using AppColors.secondary (Blue)
    return Drawer(
      backgroundColor: AppColors.secondary,
      child: SafeArea(
        child: Column(
          children: [
            // Custom Profile Header
            // "profile ki jaga icon use krlena size chota hi rkhna"
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Small Profile Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            authController.userName.value.isNotEmpty
                                ? authController.userName.value
                                : 'Ahmed Ali',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            authController.userEmail.value.isNotEmpty
                                ? authController.userEmail.value
                                : 'ahmed@example.com',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(
              color: Colors.white12,
              thickness: 1,
              indent: 24,
              endIndent: 24,
            ),

            const SizedBox(height: 16),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...NavigationConfig.items.map((item) {
                    if (item.submenu != null && item.submenu!.isNotEmpty) {
                      return Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Icon(item.icon, color: Colors.white),
                          title: Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          childrenPadding: const EdgeInsets.only(left: 16),
                          children: item.submenu!.map((subItem) {
                            return ListTile(
                              leading: Icon(
                                subItem.icon,
                                color: Colors.white70,
                                size: 20,
                              ),
                              title: Text(
                                subItem.label,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () {
                                if (subItem.route != null) {
                                  Get.back(); // Close drawer
                                  Get.toNamed(subItem.route!);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      return ListTile(
                        leading: Icon(item.icon, color: Colors.white),
                        title: Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
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

            // Bottom "Sign out" Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 48, // Restored to standard height to fix clipping
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Sign Out",
                      middleText: "Are you sure you want to sign out?",
                      textConfirm: "Yes, Sign Out",
                      textCancel: "Cancel",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red.shade400,
                      cancelTextColor: Colors.black,
                      onConfirm: () {
                        Get.back(); // Close dialog
                        authController.logout();
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400, // Distinct soft red
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
