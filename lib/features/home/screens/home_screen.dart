import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/navigation_menu.dart';
import '../widgets/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Black Diamond ERP'),
        backgroundColor: AppColors.primary,
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
            // Quick Access Section (Using hardcoded items for top row as per screenshot or user request)
            _buildSectionHeader(context, "Quick Access"),
            const SizedBox(height: 12),
            _buildQuickAccessGrid(context),

            const SizedBox(height: 24),

            // Masters
            _buildSectionHeader(context, "Masters"),
            const SizedBox(height: 12),
            _buildCategoryGrid(context, "Masters"),

            const SizedBox(height: 24),

            // Sales
            _buildSectionHeader(context, "Sales & Ops"),
            const SizedBox(height: 12),
            _buildCategoryGrid(context, "Sales & Ops"),

            const SizedBox(height: 24),

            // Inventory
            _buildSectionHeader(context, "Inventory"),
            const SizedBox(height: 12),
            _buildCategoryGrid(context, "Inventory"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    // Manually picking some important items for "Quick Access"
    final quickItems = [
      MenuItem(label: "Add Sale", icon: Icons.post_add, route: "/sales/new"),
      MenuItem(
        label: "Invoices",
        icon: Icons.receipt_long,
        route: "/sales/invoices",
      ),
      MenuItem(
        label: "Stock",
        icon: Icons.warehouse,
        route: "/inventory/stock",
      ),
      MenuItem(
        label: "Production",
        icon: Icons.precision_manufacturing,
        route: "/inventory/production",
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: quickItems.length,
      itemBuilder: (context, index) {
        return _buildGridItem(context, quickItems[index]);
      },
    );
  }

  Widget _buildCategoryGrid(BuildContext context, String categoryLabel) {
    // Find the category in config
    final category = NavigationConfig.items.firstWhere(
      (item) => item.label == categoryLabel,
      orElse: () => const MenuItem(label: "", icon: Icons.error), // fallback
    );

    if (category.submenu == null || category.submenu!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: category.submenu!.length,
      itemBuilder: (context, index) {
        return _buildGridItem(context, category.submenu![index]);
      },
    );
  }

  Widget _buildGridItem(BuildContext context, MenuItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
