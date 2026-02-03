import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/inventory_controller.dart';
import '../../products/models/product_model.dart';
import 'dart:async';

class ProductionEntryItem {
  final ProductModel product;
  double qty;

  ProductionEntryItem({required this.product, this.qty = 0});
}

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final controller = Get.put(InventoryController()); // Ensure controller

  final TextEditingController _searchController = TextEditingController();
  final List<ProductionEntryItem> _batchItems = []; // Local list

  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      controller.searchProductsForAdjustment(query);
    });
  }

  void _addItemToBatch(ProductModel p) {
    setState(() {
      // Check duplicate
      final existing = _batchItems.firstWhereOrNull(
        (i) => i.product.id == p.id,
      );
      if (existing == null) {
        _batchItems.add(ProductionEntryItem(product: p));
      } else {
        Get.snackbar('Info', 'Product already in list');
      }
    });
    Get.back(); // close sheet
  }

  void _removeItem(int index) {
    setState(() {
      _batchItems.removeAt(index);
    });
  }

  void _submitBatch() async {
    if (_batchItems.isEmpty) return;

    // Validate quantities
    final invalid = _batchItems.where((i) => i.qty <= 0).toList();
    if (invalid.isNotEmpty) {
      Get.snackbar('Error', 'Please enter valid quantity for all items');
      return;
    }

    FocusScope.of(context).unfocus();

    // Loop through
    // Note: InventoryController.adjustStock handles loading state globally.
    // If we call it in loop, it might flicker loading.
    // Ideally we should have a bulk endpoint.
    // But per instructions we loop.

    // We can manually set loading
    bool allSuccess = true;
    controller.isLoading.value = true;

    for (var item in _batchItems) {
      // We can iterate calls
      // We reuse the service logic but bypass controller's loading/snackbar to do it once?
      // Let's just call controller logic. It might spam snackbars.
      // Better to bypass controller wrapper and use service?
      // But controller has the logic for type conversion.
      // Let's modify controller to allow "silent" update or just live with multiple snackbars/loading for now
      // OR: implement bulk logic here simply.

      // actually, adjustStock in controller does:
      // isLoading = true -> service -> snackbar -> isLoading = false.
      // If we await sequentially, it will work.

      final success = await controller.adjustStock(
        productId: item.product.id!,
        type: 'IN', // Production is always Add
        qty: item.qty,
        note: 'Production Entry',
      );
      if (!success) allSuccess = false;
    }

    // Controller sets loading to false at end of each call.
    if (allSuccess) {
      Get.snackbar('Success', 'Batch production recorded');
      setState(() {
        _batchItems.clear();
      });
    } else {
      Get.snackbar('Warning', 'Some items failed to record');
    }
  }

  void _showProductSelectionSheet() {
    controller.productSearchResults.clear();
    _searchController.clear();
    controller.searchProductsForAdjustment('');

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Search Product',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isSearchingProducts.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.productSearchResults.isEmpty) {
                  return const Center(child: Text('Start typing to search...'));
                }
                return ListView.separated(
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemCount: controller.productSearchResults.length,
                  itemBuilder: (context, index) {
                    final p = controller.productSearchResults[index];
                    return ListTile(
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'SKU: ${p.sku ?? '-'}',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      trailing: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                      ),
                      onTap: () => _addItemToBatch(p),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Production Entry',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {}, // Future history
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Area: Add Product Button & Search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                InkWell(
                  onTap: _showProductSelectionSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Search & Add Product...',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Spacer(),
                        const Icon(Icons.add, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _batchItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers_clear,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items added to batch',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Tap search above to start',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _batchItems.length,
                    itemBuilder: (context, index) {
                      final item = _batchItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Product Info
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item.product.sku != null)
                                      Text(
                                        item.product.sku!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Qty Input
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Qty',
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  onChanged: (val) {
                                    item.qty = double.tryParse(val) ?? 0;
                                  },
                                ),
                              ),

                              // Remove
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(
                  () => ElevatedButton(
                    onPressed:
                        (controller.isLoading.value || _batchItems.isEmpty)
                        ? null
                        : _submitBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Confirm Batch (${_batchItems.length} items)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
