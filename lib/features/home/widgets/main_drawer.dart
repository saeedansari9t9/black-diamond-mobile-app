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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: const Color.fromARGB(226, 0, 63, 146),
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
                      return Column(
                        children: [
                          Theme(
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
                                return Column(
                                  children: [
                                    ListTile(
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
                                    ),
                                    Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.withOpacity(0.8),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          ListTile(
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
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ],
                      );
                    }
                  }),
                  // Added Sign Out as the last menu item
                  Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onTap: () {
                          Get.dialog(
                            Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.white,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                width: 300,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Sign Out",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Are you sure you want to sign out?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.grey,
                                          ),
                                          child: const Text("Cancel"),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                            authController.logout();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade400,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                          ),
                                          child: const Text("Sign Out"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
