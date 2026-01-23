import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/sales_controller.dart';
import '../../products/controllers/product_controller.dart';
import '../../customers/controllers/customer_controller.dart';

class AddSaleScreen extends StatelessWidget {
  const AddSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesController());

    // Ensure product controller is available for search
    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Basic responsive switch: if width > 600, maybe row layout?
          // For now, let's just properly constrain the scrollable area.
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 100,
                    ), // Reserve for bottom bar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Customer Selection
                        _buildCustomerSection(controller),
                        const SizedBox(height: 16),

                        // Cart Section
                        _buildCartSection(controller, context),
                        const SizedBox(height: 16),

                        // Payment & Totals
                        _buildTotalsSection(controller),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerSection(SalesController controller) {
    if (!Get.isRegistered<CustomerController>()) {
      Get.put(CustomerController());
    }
    final customerController = Get.find<CustomerController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedCustomerId.value == null
                          ? 'walk-in'
                          : 'existing',
                      decoration: const InputDecoration(
                        labelText: 'Customer Type',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'walk-in',
                          child: Text('Walk-in Customer'),
                        ),
                        DropdownMenuItem(
                          value: 'existing',
                          child: Text('Existing Customer'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == 'walk-in') {
                          controller.selectedCustomerName.value = 'Walk-in';
                          controller.selectedCustomerId.value = null;
                        } else {
                          // Trigger fetch if empty
                          if (customerController.customers.isEmpty) {
                            customerController.fetchCustomers();
                          }
                          // Reset name if switching to existing, until selected
                          controller.selectedCustomerName.value = '';
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              // If Walk-in, show text input
              if (controller.selectedCustomerId.value == null &&
                  (controller.selectedCustomerName.value == 'Walk-in' ||
                      controller.selectedCustomerName.value.isEmpty &&
                          controller.selectedCustomerId.value == null)) {
                // Logic check above is slightly complex because 'existing' but not selected yields null ID.
                // Let's rely on the dropdown value logic we implemented:
                // If user selected 'existing' in dropdown, we want to show customer picker.
                // But we don't store "type" in controller, we infer from ID.
                // This is tricky. Let's simplify:
                // If ID is null, we assume walk-in unless we are in "selection mode".
                // BUT, user might want to select existing.

                // Better approach: Show search/dropdown for existing if "existing" selected.
                // Since we don't have a separate "type" observable, let's just show both widgets based on state.
                return const SizedBox.shrink();
              }
              return const SizedBox.shrink();
            }),

            // Improved UI: Always show either Name Input (for Walk-in) or Dropdown (for Existing)
            // We need a local state for the "type" or add it to controller.
            // For now, let's use the UI state we just added in the build method? No, StatelessWidget.
            // Let's use a simpler approach:
            Obx(() {
              // Fix: We will assume if ID is null, it's walk-in, UNLESS we want to pick.
              // Let's just show the Customer Search button if "Existing" is desired.

              return Column(
                children: [
                  if (controller.selectedCustomerId.value == null)
                    TextFormField(
                      initialValue: controller.selectedCustomerName.value,
                      decoration: const InputDecoration(
                        labelText: 'Walk-in Name',
                      ),
                      onChanged: (val) =>
                          controller.selectedCustomerName.value = val,
                    )
                  else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(controller.selectedCustomerName.value),
                      subtitle: const Text('Selected Customer'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.selectedCustomerId.value = null;
                          controller.selectedCustomerName.value = 'Walk-in';
                        },
                      ),
                    ),

                  if (controller.selectedCustomerId.value == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: () => _showCustomerSearch(
                          Get.context!,
                          controller,
                          customerController,
                        ),
                        icon: const Icon(Icons.person_search),
                        label: const Text('Select Existing Customer'),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCustomerSearch(
    BuildContext context,
    SalesController salesController,
    CustomerController customerController,
  ) {
    if (customerController.customers.isEmpty)
      customerController.fetchCustomers();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search Customer...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => customerController.fetchCustomers(query: val),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (customerController.isLoading.value)
                  return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: customerController.customers.length,
                  itemBuilder: (context, index) {
                    final c = customerController.customers[index];
                    return ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.phone ?? ''),
                      onTap: () {
                        salesController.selectedCustomerId.value = c.id;
                        salesController.selectedCustomerName.value = c.name;
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
    );
  }

  Widget _buildCartSection(SalesController controller, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () => _showProductSearch(context, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ],
            ),
            Obx(() {
              if (controller.cartItems.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Cart is empty')),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.productName ?? 'Product'),
                    subtitle: Text('${item.qty} x ${item.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.lineTotal.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (item.qty > 1) {
                              controller.updateItem(
                                index,
                                item.qty - 1,
                                item.price,
                              );
                            } else {
                              controller.removeItem(index);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            controller.updateItem(
                              index,
                              item.qty + 1,
                              item.price,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showProductSearch(
    BuildContext context,
    SalesController salesController,
  ) {
    final productController = Get.find<ProductController>();
    productController.fetchProducts(); // Reset list

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.background,
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search SKU...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (val) => productController.fetchProducts(query: val),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (productController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (productController.products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: productController.products.length,
                    itemBuilder: (context, index) {
                      final product = productController.products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('SKU: ${product.sku}'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            color: AppColors.secondary,
                          ),
                          onPressed: () {
                            salesController.addItem(product);
                            Get.back();
                            Get.snackbar(
                              'Added',
                              '${product.name} added to cart',
                              duration: const Duration(seconds: 1),
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsSection(SalesController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => _buildSummaryRow(
                'Subtotal',
                controller.subTotal.toStringAsFixed(2),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Discount'),
                const Spacer(),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (val) =>
                        controller.discount.value = double.tryParse(val) ?? 0,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Obx(
              () => _buildSummaryRow(
                'Grand Total',
                controller.grandTotal.toStringAsFixed(2),
                isBold: true,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Use Column on mobile or if constrained, otherwise Row
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we should stack fields (e.g. if width is small)
                bool isNarrow = constraints.maxWidth < 600;

                if (isNarrow) {
                  return Column(
                    children: [
                      Obx(
                        () => DropdownButtonFormField<String>(
                          value: controller.paymentMethod.value,
                          decoration: const InputDecoration(
                            labelText: 'Method',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'bank',
                              child: Text('Bank Transfer'),
                            ),
                            DropdownMenuItem(
                              value: 'credit',
                              child: Text('Credit'),
                            ),
                          ],
                          onChanged: (v) => controller.paymentMethod.value = v!,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Paid Amount',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                        ),
                        onChanged: (val) => controller.paidAmount.value =
                            double.tryParse(val) ?? 0,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          value: controller.paymentMethod.value,
                          decoration: const InputDecoration(
                            labelText: 'Method',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'bank',
                              child: Text('Bank Transfer'),
                            ),
                            DropdownMenuItem(
                              value: 'credit',
                              child: Text('Credit'),
                            ),
                          ],
                          onChanged: (v) => controller.paymentMethod.value = v!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Paid Amount',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                        ),
                        onChanged: (val) => controller.paidAmount.value =
                            double.tryParse(val) ?? 0,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Obx(
              () => _buildSummaryRow(
                'Due Amount',
                controller.dueAmount.toStringAsFixed(2),
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(SalesController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.submitSale,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SUBMIT SALE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
