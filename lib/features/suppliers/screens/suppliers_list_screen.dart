import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/supplier_controller.dart';
import 'add_supplier_screen.dart';
import 'supplier_ledger_screen.dart';

class SuppliersListScreen extends StatelessWidget {
  const SuppliersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupplierController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suppliers'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => Get.to(() => const AddSupplierScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.suppliers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.suppliers.isEmpty) {
          return const Center(child: Text('No suppliers found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.suppliers.length,
          itemBuilder: (context, index) {
            final item = controller.suppliers[index];
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
                subtitle: Text(
                  '${item.category} • Wallet: ${item.walletBalance}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.receipt_long, color: Colors.blue),
                      tooltip: 'View Ledger',
                      onPressed: () =>
                          Get.to(() => SupplierLedgerScreen(supplier: item)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.secondary),
                      onPressed: () => Get.to(
                        () => const AddSupplierScreen(),
                        arguments: item,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => controller.deleteSupplier(item.id!),
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
