import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/navigation_menu.dart';
import '../../sales/models/sale_model.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded.
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }

    // Flatten all items into a single list
    final List<MenuItem> dashboardItems = _getDashboardItems();

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.5),

      appBar: AppBar(
        title: const Text('Black Diamond'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),

        actions: [
          IconButton(
            onPressed: () {
              if (Get.isRegistered<DashboardController>()) {
                Get.find<DashboardController>().fetchStats();
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          // 1. Unified Stats Box
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildUnifiedStatsBox(context),
            ),
          ),

          // 2. Today's Total Sell Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Today's Total Sell",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // 3. ✅ Today's Sales (BOX + INNER SCROLL)
          _buildTodaySalesBoxSliver(context),

          // 4. Shortcut Grid Box (Unified)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // First Row
                    _buildShortcutRow(context, dashboardItems.take(4).toList()),

                    // Horizontal Divider (Inset)
                    if (dashboardItems.length > 4)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 1,
                        color: Colors.grey.withOpacity(0.15),
                      ),

                    // Second Row
                    if (dashboardItems.length > 4)
                      _buildShortcutRow(
                        context,
                        dashboardItems.skip(4).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // --- Unified Stats Box ---
  Widget _buildUnifiedStatsBox(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(() {
        final currencyFormat = NumberFormat.currency(
          symbol: 'PKR ',
          decimalDigits: 0,
        );
        final isLoading = controller.isLoading.value;

        Widget buildStatItem(String label, String value, IconData icon) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              isLoading
                  ? Container(
                          width: 80,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.2,
                            ), // Base color container
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                        .animate(onPlay: (anim) => anim.repeat())
                        .shimmer(
                          duration: const Duration(milliseconds: 1200),
                          color: Colors.white.withOpacity(
                            0.8,
                          ), // A brighter color for the shimmer wave
                          blendMode: BlendMode
                              .srcATop, // Allows the wave to sit on top properly
                        )
                  : Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: buildStatItem(
                    'Today Sales',
                    currencyFormat.format(controller.todaySalesTotal.value),
                    CupertinoIcons.money_dollar,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white24,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: buildStatItem(
                    'Monthly Sales',
                    currencyFormat.format(controller.monthlySalesTotal.value),
                    CupertinoIcons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: buildStatItem(
                    'Today Orders',
                    '${controller.todayOrders.value}',
                    CupertinoIcons.cart,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white24,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: buildStatItem(
                    'Monthly Orders',
                    '${controller.monthlyOrders.value}',
                    CupertinoIcons.calendar,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // --- ✅ Today's Sales BOX Sliver (Inner Scroll) ---
  Widget _buildTodaySalesBoxSliver(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.withOpacity(0.12),
                          ),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: 50,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Container(
                                        width: 40,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Container(
                                        width: 50,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width: 48,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (anim) => anim.repeat())
                .shimmer(
                  duration: const Duration(milliseconds: 1200),
                  color: Colors.white60,
                );
          }

          if (controller.todaySalesList.isEmpty) {
            return Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: const Text(
                'No sales today',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // ✅ Optional: dynamic height (max 380)
          final int count = controller.todaySalesList.length;
          final double base = 120; // header + footer approx
          final double rowH = 56;
          final double maxH = 260;
          final double height = (base + (count * rowH))
              .clamp(240, maxH)
              .toDouble();

          return Container(
            height: height, // ✅ fixed/dynamic height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // ✅ Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Customer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Time',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Action',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Inner Scroll List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.todaySalesList.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey.withOpacity(0.12),
                    ),
                    itemBuilder: (context, index) {
                      final sale = controller.todaySalesList[index];
                      final isWalkIn =
                          (sale.customerName?.toLowerCase() ?? 'walk-in') ==
                          'walk-in';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8, // Reduced padding
                        ),
                        child: Row(
                          children: [
                            // Customer
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sale.customerName ?? 'Walk-in',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12, // Reduced font
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isWalkIn
                                          ? Colors.grey.withOpacity(0.1)
                                          : AppColors.secondary.withOpacity(
                                              0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isWalkIn ? 'Walk-in' : 'Old Customer',
                                      style: TextStyle(
                                        fontSize: 9, // Small font
                                        color: isWalkIn
                                            ? Colors.grey[700]
                                            : AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Time
                            Expanded(
                              flex: 2,
                              child: Text(
                                sale.createdAt != null
                                    ? DateFormat(
                                        'hh:mm a',
                                      ).format(sale.createdAt!)
                                    : '-',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            // Total
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Rs. ${NumberFormat("#,##0").format(sale.grandTotal)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            // Action Button
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _showSaleDetails(context, sale),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('View'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ✅ Footer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      // your widgets
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // --- Sale Details Popup ---
  void _showSaleDetails(BuildContext context, SaleModel sale) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sale Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Text(
                'Invoice #${sale.invoiceNo ?? 'N/A'} • ${sale.createdAt != null ? DateFormat('MM/dd/yyyy, hh:mm a').format(sale.createdAt!) : ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        sale.customerName ?? 'Walk-in',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sale.paymentMethod.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 4,
                      child: Text(
                        'Item',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Price',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Total',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sale.items.length,
                  itemBuilder: (context, index) {
                    final item = sale.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName ?? 'Product',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (item.sku != null)
                                  Text(
                                    item.sku!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${item.qty.toInt()}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${item.price.toInt()}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${item.lineTotal.toInt()}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(),

              _buildTotalRow('Subtotal', sale.subTotal),
              _buildTotalRow('Discount', -sale.discount, color: Colors.red),
              const SizedBox(height: 8),
              _buildTotalRow(
                'Grand Total',
                sale.grandTotal,
                isBold: true,
                fontSize: 18,
              ),
              const SizedBox(height: 8),
              _buildTotalRow(
                'Paid',
                sale.paidAmount,
                color: Colors.green,
                fontSize: 14,
              ),
              _buildTotalRow(
                'Due',
                sale.dueAmount,
                color: Colors.red,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            NumberFormat.simpleCurrency(
              name: '',
              decimalDigits: 0,
            ).format(amount),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to flatten the menu hierarchy
  List<MenuItem> _getDashboardItems() {
    List<MenuItem> flattened = [];
    for (var item in NavigationConfig.items) {
      if (item.route == '/dashboard') continue;
      if (item.submenu != null) {
        flattened.addAll(item.submenu!);
      } else {
        flattened.add(item);
      }
    }

    // Limit to 7 and add View All
    if (flattened.length > 7) {
      var limited = flattened.take(7).toList();
      limited.add(
        const MenuItem(
          label: 'View All',
          icon: CupertinoIcons.square_grid_2x2,
          route: '/all-services',
        ),
      );
      return limited;
    }
    return flattened;
  }

  Widget _buildShortcutRow(BuildContext context, List<MenuItem> items) {
    List<Widget> children = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Item Widget
      children.add(
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (item.route != null) {
                  Get.toNamed(item.route!);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: AppColors.secondary, size: 28),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Vertical Divider (if not last item)
      if (i < items.length - 1) {
        children.add(
          Container(
            width: 1,
            height: 30, // Small height
            color: Colors.grey.withOpacity(0.15),
          ),
        );
      }
    }

    // Fill missing slots if row has < 4 items (to keep alignment)
    if (items.length < 4) {
      for (int i = 0; i < (4 - items.length); i++) {
        // Add spacer + potential divider
        if (children.isNotEmpty && children.last is! Container) {
          children.add(
            Container(width: 1, height: 30, color: Colors.transparent),
          );
        }
        children.add(const Expanded(child: SizedBox()));
      }
    }

    return Row(children: children);
  }
}
