import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/sales_controller.dart';
import '../models/sale_model.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesController());
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchSales,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/sales/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search Invoice #',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (v) => controller.searchInvoice.value = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search Customer',
                          prefixIcon: Icon(Icons.person_search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (v) => controller.searchCustomer.value = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          value: controller.customerTypeFilter.value,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Types'),
                            ),
                            DropdownMenuItem(
                              value: 'walkin',
                              child: Text('Walk-in'),
                            ),
                            DropdownMenuItem(
                              value: 'regular',
                              child: Text('Registered'),
                            ),
                          ],
                          onChanged: (v) =>
                              controller.customerTypeFilter.value = v!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Date Filter Buttons could go here, for simplicity treating as advanced or separate for now
                    // The user provided date inputs in React, let's keep it simple for Mobile or add if needed.
                    // Mobile space is limited.
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sales.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = controller.filteredSales;

              if (filtered.isEmpty) {
                return const Center(
                  child: Text('No invoices found matching criteria.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final sale = filtered[index];
                  final isWalkIn =
                      (sale.customerName ?? '').toLowerCase() == 'walk-in';
                  final date = sale.createdAt ?? DateTime.now();

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          Get.to(() => InvoiceDetailScreen(sale: sale)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  sale.invoiceNo ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, hh:mm a').format(date),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sale.customerName ?? 'Walk-in',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isWalkIn
                                            ? Colors.orange[50]
                                            : Colors.purple[50],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isWalkIn
                                              ? Colors.orange[100]!
                                              : Colors.purple[100]!,
                                        ),
                                      ),
                                      child: Text(
                                        isWalkIn ? 'Walk-in' : 'Registered',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isWalkIn
                                              ? Colors.orange[800]
                                              : Colors.purple[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormat.format(sale.grandTotal),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (sale.dueAmount > 0)
                                      Text(
                                        'Due: ${currencyFormat.format(sale.dueAmount)}',
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else
                                      const Text(
                                        'Paid',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
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
