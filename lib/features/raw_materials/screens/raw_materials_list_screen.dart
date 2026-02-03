import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/raw_material_controller.dart';
import 'add_raw_material_screen.dart';

class RawMaterialsListScreen extends StatelessWidget {
  const RawMaterialsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RawMaterialController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Raw Materials'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => Get.to(() => const AddRawMaterialScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rawMaterials.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rawMaterials.isEmpty) {
          return const Center(child: Text('No raw materials found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.rawMaterials.length,
          itemBuilder: (context, index) {
            final item = controller.rawMaterials[index];
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
                    item.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Attributes: ${item.attributes.length}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.secondary),
                      onPressed: () => Get.to(
                        () => const AddRawMaterialScreen(),
                        arguments: item,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => controller.deleteRawMaterial(item.id!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
