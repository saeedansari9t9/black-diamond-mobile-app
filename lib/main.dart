import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'core/widgets/placeholder_screen.dart';
import 'features/materials/screens/materials_list_screen.dart';
import 'features/materials/screens/add_material_screen.dart';
import 'features/products/screens/products_list_screen.dart';
import 'features/products/screens/add_product_screen.dart';
import 'features/users/screens/users_list_screen.dart';
import 'features/users/screens/add_user_screen.dart';
import 'features/sales/screens/add_sale_screen.dart';
import 'features/customers/screens/customers_list_screen.dart';
import 'features/customers/screens/add_customer_screen.dart';

import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const BlackDiamondApp());
}

class BlackDiamondApp extends StatelessWidget {
  const BlackDiamondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Black Diamond',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      getPages: [
        // Masters
        GetPage(
          name: '/masters/materials',
          page: () => const MaterialsListScreen(),
        ),
        GetPage(
          name: '/masters/materials/add',
          page: () => const AddMaterialScreen(),
        ),
        GetPage(
          name: '/masters/products',
          page: () => const ProductsListScreen(),
        ),
        GetPage(
          name: '/masters/products/add',
          page: () => const AddProductScreen(),
        ),

        // Settings
        GetPage(name: '/users', page: () => const UsersListScreen()),
        GetPage(name: '/users/add', page: () => const AddUserScreen()),

        // Placeholders
        GetPage(
          name: '/inventory/raw-materials',
          page: () => const PlaceholderScreen(title: 'Raw Materials'),
        ),
        GetPage(
          name: '/sales/new',
          page: () => const PlaceholderScreen(title: 'New Sale'),
        ),
        GetPage(
          name: '/sales/invoices',
          page: () => const PlaceholderScreen(title: 'Invoices'),
        ),
        GetPage(
          name: '/inventory/stock',
          page: () => const PlaceholderScreen(title: 'Stock'),
        ),
        GetPage(
          name: '/inventory/production',
          page: () => const PlaceholderScreen(title: 'Production'),
        ),
        GetPage(
          name: '/inventory/adjust-stock',
          page: () => const PlaceholderScreen(title: 'Adjust Stock'),
        ),
        GetPage(
          name: '/purchases',
          page: () => const PlaceholderScreen(title: 'Purchases'),
        ),
        GetPage(
          name: '/purchases/new',
          page: () => const PlaceholderScreen(title: 'New Purchase'),
        ),
        GetPage(
          name: '/purchases/suppliers',
          page: () => const PlaceholderScreen(title: 'Suppliers'),
        ),
        GetPage(
          name: '/reports/sales',
          page: () => const PlaceholderScreen(title: 'Sales Report'),
        ),
        // Sales
        GetPage(name: '/sales/add', page: () => const AddSaleScreen()),

        // Customers
        GetPage(name: '/customers', page: () => const CustomersListScreen()),
        GetPage(name: '/customers/add', page: () => const AddCustomerScreen()),
      ],
    );
  }
}
