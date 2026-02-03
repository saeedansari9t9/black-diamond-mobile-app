import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/navigation_menu.dart';
import '../widgets/main_drawer.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Flatten all items into a single list
    final List<MenuItem> dashboardItems = _getDashboardItems();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Black Diamond ERP'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open the drawer of the parent Scaffold (HomeScreen)
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      // drawer: const MainDrawer(), // Removed: moved to HomeScreen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Section
            _buildStatsSection(context),

            const SizedBox(height: 24),

            // Grid Menu
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 120, // Responsive sizing
                childAspectRatio: 0.85, // Tweak for icon + text balance
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: dashboardItems.length,
              itemBuilder: (context, index) {
                return _buildGridItem(context, dashboardItems[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 4 Stats Cards in a 2x2 Grid using Wrap or GridView
  Widget _buildStatsSection(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Currency Formatter
      final currencyFormat = NumberFormat.currency(
        symbol: 'PKR ',
        decimalDigits: 0,
      );

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _buildStatCard(
            context,
            title: 'Monthly Sales',
            value: currencyFormat.format(controller.totalSales.value),
            icon: CupertinoIcons.money_dollar_circle_fill,
            color: Colors.blueAccent,
          ),
          _buildStatCard(
            context,
            title: 'Monthly Orders',
            value: '${controller.totalOrders.value}',
            icon: CupertinoIcons.cart_fill,
            color: Colors.orangeAccent,
          ),
          _buildStatCard(
            context,
            title: 'Customers',
            value: '${controller.totalCustomers.value}',
            icon: CupertinoIcons.person_2_fill,
            color: Colors.greenAccent,
          ),
          _buildStatCard(
            context,
            title: 'Suppliers',
            value: '${controller.totalSuppliers.value}',
            icon: CupertinoIcons.cube_box_fill,
            color: Colors.purpleAccent,
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Smaller icon container
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18), // Smaller icon
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  // Smaller font
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11, // Smaller font
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to flatten the menu hierarchy
  List<MenuItem> _getDashboardItems() {
    final List<MenuItem> flattenedItems = [];
    for (var item in NavigationConfig.items) {
      // Skip the dashboard entry itself to avoid recursion/redundancy
      if (item.route == '/dashboard') continue;

      if (item.submenu != null && item.submenu!.isNotEmpty) {
        // If it has a submenu, add all submenu items
        flattenedItems.addAll(item.submenu!);
      } else {
        // Otherwise add the item itself (e.g., Customers)
        flattenedItems.add(item);
      }
    }
    return flattenedItems;
  }

  Widget _buildGridItem(BuildContext context, MenuItem item) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleNavigation(item),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.secondary,
                    size:
                        32, // Slightly larger for better touch target/visibility
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(MenuItem item) {
    if (item.route != null && item.route!.isNotEmpty) {
      try {
        // Attempt to navigate
        // Check if the route is actually registered in GetX pages would be ideal,
        // but for now we try/catch.
        // However, Get.toNamed() might not throw immediately if not found, depending on config.
        // But preventing crashes is good.
        // The user said: "bhale coming soon show krrwao" (even if it shows Coming Soon)

        // We can manually filter known placeholder routes if we had them.
        Get.toNamed(item.route!);
      } catch (e) {
        _showComingSoonSnackbar(item.label);
      }
    } else {
      _showComingSoonSnackbar(item.label);
    }
  }

  void _showComingSoonSnackbar(String featureName) {
    Get.snackbar(
      "Coming Soon",
      "$featureName is under development.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }
}
