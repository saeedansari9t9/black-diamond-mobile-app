import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/navigation_menu.dart';
import '../widgets/main_drawer.dart';

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
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: const MainDrawer(),
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6, // Adjust for smaller, wider cards
      children: [
        _buildStatCard(
          context,
          title: 'Total Sales',
          value: '\$12,450',
          icon: CupertinoIcons.money_dollar_circle_fill,
          color: Colors.blueAccent,
        ),
        _buildStatCard(
          context,
          title: 'Orders',
          value: '45',
          icon: CupertinoIcons.cart_fill,
          color: Colors.orangeAccent,
        ),
        _buildStatCard(
          context,
          title: 'Customers',
          value: '128',
          icon: CupertinoIcons.person_2_fill,
          color: Colors.greenAccent,
        ),
        _buildStatCard(
          context,
          title: 'Pending',
          value: '12',
          icon: CupertinoIcons.clock_fill,
          color: Colors.redAccent,
        ),
      ],
    );
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
