import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/inventory_controller.dart';
import '../../products/models/product_model.dart';
import 'dart:async';

class AdjustStockScreen extends StatefulWidget {
  const AdjustStockScreen({super.key});

  @override
  State<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends State<AdjustStockScreen> {
  // Ensure controller exists
  final controller = Get.put(InventoryController());

  ProductModel? selectedProduct;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedType = 'IN'; // Used for UI toggle: IN (Add) / OUT (Remove)
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _noteController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      controller.searchProductsForAdjustment(query);
    });
  }

  void _submit() async {
    if (selectedProduct == null) {
      Get.snackbar('Error', 'Please select a product');
      return;
    }
    final qty = double.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      Get.snackbar('Error', 'Invalid quantity');
      return;
    }

    FocusScope.of(context).unfocus();

    // Map UI Type to signed quantity for 'adjust' backend type
    // IN = Positive, OUT = Negative
    double finalQty = _selectedType == 'IN' ? qty : -qty;

    final success = await controller.adjustStock(
      productId: selectedProduct!.id!,
      type: 'adjust',
      qty:
          finalQty, // Controller handles strict 'adjust' type but we pass signed here to be safe if Logic changes
      note: _noteController.text,
    );

    // Wait for controller to finish (it returns bool)
    if (success) {
      // Clear fields for next entry or go back?
      // User might want to do multiple. Let's clear forms.
      setState(() {
        selectedProduct = null;
        _qtyController.clear();
        _noteController.clear();
      });
      // Optional: Get.back(); if single use
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.sku != null)
                            Text(
                              p.sku!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: Colors.blueGrey,
                              ),
                            ),
                          // Show current stock if available in product model?
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          selectedProduct = p;
                        });
                        Get.back();
                      },
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
    // Modify adjustStock in controller to accept signed qty directly if my previous change didn't covers it completely
    // But Step 530 showed I updated controller to use 'adjust' type.
    // And logic there was: try { ... qtyChange: change }
    // Controller logic (lines 72-74 of Step 526) calculates 'change' based on type passed to it (IN/OUT).
    // So if I pass 'IN' here, controller uses +qty. If 'OUT', -qty.
    // Wait, in Step 530 I hardcoded type: 'adjust'.
    // BUT I kept `qtyChange: change`.
    // And `change` is calculated from `type` argument passed to `adjustStock` func.
    // So calling `controller.adjustStock(..., type: 'IN', ...)` is correct usage.

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Adjust Stock',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Text(
              'Manually update inventory levels',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Select Product
                  const Text(
                    'Select Product',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showProductSelectionSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: selectedProduct == null
                                ? Text(
                                    'Select a product...',
                                    style: TextStyle(color: Colors.grey[500]),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedProduct!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (selectedProduct!.sku != null)
                                        Text(
                                          selectedProduct!.sku!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                          if (selectedProduct != null)
                            IconButton(
                              icon: const Icon(
                                Icons.change_circle_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: _showProductSelectionSheet, // Re-open
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Action (Add/Remove) & Quantity
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Action',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedType = 'IN'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: _selectedType == 'IN'
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: _selectedType == 'IN'
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              size: 16,
                                              color: _selectedType == 'IN'
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Add',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _selectedType == 'IN'
                                                    ? Colors.green
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedType = 'OUT'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: _selectedType == 'OUT'
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: _selectedType == 'OUT'
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: _selectedType == 'OUT'
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Remove',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _selectedType == 'OUT'
                                                    ? Colors.red
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _qtyController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                hintText: '0',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Reason / Note
                  const Text(
                    'Reason / Note',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText:
                          'e.g. Broken items, Inventory count correction...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                // Controller logic expects 'IN' or 'OUT' to calculate signed change.
                                // My _submit() above handles simple controller call.
                                // Let's call controller using 'IN'/'OUT' arguments so its logic works.

                                if (selectedProduct == null) {
                                  Get.snackbar(
                                    'Error',
                                    'Please select a product',
                                  );
                                  return;
                                }
                                final qty = double.tryParse(
                                  _qtyController.text,
                                );
                                if (qty == null || qty <= 0) {
                                  Get.snackbar('Error', 'Invalid quantity');
                                  return;
                                }

                                FocusScope.of(context).unfocus();
                                controller
                                    .adjustStock(
                                      productId: selectedProduct!.id!,
                                      type: _selectedType, // IN or OUT
                                      qty: qty,
                                      note: _noteController.text,
                                    )
                                    .then((success) {
                                      if (success) {
                                        setState(() {
                                          // selectedProduct = null; // Keep product selected? User said "beautiful", maybe keep it?
                                          // usually clear is safer.
                                          _qtyController.clear();
                                          _noteController.clear();
                                        });
                                      }
                                    });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Confirm Stock Adjustment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
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
