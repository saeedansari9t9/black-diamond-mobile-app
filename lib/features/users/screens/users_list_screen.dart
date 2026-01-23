import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => Get.toNamed(
          '/users/add',
        ), // We need to register this route if dynamic, or just push
        // Actually main.dart doesn't have /users/add, only /users.
        // I will use direct navigation or update main.dart routes later.
        // For now, let's use a simple Get.to since it's cleaner in GetX
        // But better practice is named routes. I will create AddUserScreen first.
        // Let's assume I'll add the route or use Get.to for now.
        // Since I haven't registered /users/add in getPages yet, I'll use simple PageRoute for now or register it.
        // I'll stick to Get.to for this one to save a step or update main.dart.
        // Wait, I should implement AddUserScreen and register it properly.
        // I'll register it in main.dart after this.
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (val) => controller.fetchUsers(query: val),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.users.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: user.isActive,
                        activeColor: AppColors.secondary,
                        onChanged: (val) => controller.toggleUserStatus(user),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
