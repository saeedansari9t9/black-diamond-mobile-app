import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/inventory_controller.dart';
import 'adjust_stock_screen.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stock Inventory'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchStock,
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert),
            tooltip: 'Adjust Stock',
            onPressed: () => Get.to(() => const AdjustStockScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search SKU or Material',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.stockList.isEmpty) {
                return const Center(child: Text('No stock items found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.stockList.length,
                itemBuilder: (context, index) {
                  final item = controller.stockList[index];
                  final isLowStock = item.stock < 10; // Example threshold
                  final isOutOfStock = item.stock <= 0;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.materialName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (item.sku != null)
                                      Text(
                                        item.sku!,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isOutOfStock
                                      ? Colors.red.withOpacity(0.1)
                                      : (isLowStock
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isOutOfStock
                                        ? Colors.red.withOpacity(0.3)
                                        : (isLowStock
                                              ? Colors.orange.withOpacity(0.3)
                                              : Colors.green.withOpacity(0.3)),
                                  ),
                                ),
                                child: Text(
                                  isOutOfStock
                                      ? 'Out of Stock'
                                      : (isLowStock ? 'Low Stock' : 'In Stock'),
                                  style: TextStyle(
                                    color: isOutOfStock
                                        ? Colors.red
                                        : (isLowStock
                                              ? Colors.orange
                                              : Colors.green),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Attributes
                          if (item.attributes != null &&
                              item.attributes!.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: item.attributes!.entries.map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    '${e.key}: ${e.value}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Retail',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${item.retailPrice}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wholesale',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${item.wholesalePrice}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Stock Qty',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    item.stock.toStringAsFixed(
                                      1,
                                    ), // Show decimal if needed
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: isOutOfStock
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
