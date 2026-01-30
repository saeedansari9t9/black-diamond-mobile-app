import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../controllers/product_controller.dart';

class ProductsListScreen extends StatelessWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => Get.toNamed('/masters/products/add'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by SKU...',
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
                    controller.fetchProducts();
                  },
                ),
              ),
              onSubmitted: (val) => controller.fetchProducts(query: val),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.products.isEmpty) {
                return const Center(child: Text('No products found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final item = controller.products[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary.withOpacity(0.1),
                        child: Icon(
                          Icons.inventory_2,
                          color: AppColors.secondary,
                        ),
                      ),
                      title: Text(
                        item.attributes['prodName'] ??
                            item.sku ??
                            'Unknown Product',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SKU: ${item.sku ?? "Pending"}'),
                          Text(
                            'Material: ${item.materialName}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs ${item.retailPrice}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                controller.deleteProduct(item.id!);
                              } else if (value == 'edit') {
                                Get.toNamed(
                                  '/masters/products/add',
                                  arguments: item,
                                );
                              }
                            },
                          ),
                        ],
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
