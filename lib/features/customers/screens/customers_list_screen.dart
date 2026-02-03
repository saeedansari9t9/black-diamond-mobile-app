import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/customer_controller.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller
    final controller = Get.put(CustomerController());
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: AppColors.secondary,
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
              // Initial loading
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
                  // Colors for Avatar based on index
                  final avatarColors = [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                  ];
                  final color = avatarColors[index % avatarColors.length];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        // Row 1: Info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: color,
                              radius: 20,
                              child: Text(
                                item.name.isNotEmpty
                                    ? item.name.substring(0, 1).toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (item.phone != null)
                                    Text(
                                      item.phone!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (item.address != null)
                              Expanded(
                                child: Text(
                                  item.address!,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Divider(height: 1, color: Colors.grey[100]),
                        const SizedBox(height: 12),

                        // Row 2: Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Edit
                            ActionButton(
                              label: 'Edit',
                              icon: Icons.edit,
                              color: Colors.blue,
                              bgColor: Colors.blue.shade50,
                              onTap: () {
                                // TODO: Edit
                              },
                            ),
                            const SizedBox(width: 8),
                            // Delete
                            ActionButton(
                              label: 'Delete',
                              icon: Icons.delete,
                              color: Colors.red,
                              bgColor: Colors.red.shade50,
                              onTap: () {
                                // TODO: Delete
                              },
                            ),
                            const SizedBox(width: 8),
                            // Ledger
                            ActionButton(
                              label: 'Ledger',
                              // icon: Icons.receipt_long,
                              color: Colors.green,
                              bgColor: Colors.green.shade50,
                              onTap: () {
                                Get.toNamed('/customers/${item.id}/ledger');
                              },
                            ),
                            const SizedBox(width: 8),
                            // Detail
                            ActionButton(
                              label: 'Detail',
                              color: Colors.grey.shade700,
                              bgColor: Colors.grey.shade100,
                              onTap: () {
                                // TODO: Detail
                              },
                            ),
                          ],
                        ),
                      ],
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

class ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
