import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/customer_controller.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => Get.toNamed('/customers/add'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    controller.fetchCustomers();
                  },
                ),
              ),
              onSubmitted: (val) => controller.fetchCustomers(query: val),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.customers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.customers.isEmpty) {
                return const Center(child: Text('No customers found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final item = controller.customers[index];
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
                        '${item.phone ?? ""} \n${item.address ?? ""}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
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
