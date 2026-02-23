import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'core/widgets/placeholder_screen.dart';
import 'features/materials/screens/materials_list_screen.dart';
import 'features/materials/screens/add_material_screen.dart';
import 'features/raw_materials/screens/raw_materials_list_screen.dart';
import 'features/products/screens/products_list_screen.dart';
import 'features/products/screens/add_product_screen.dart';
import 'features/users/screens/users_list_screen.dart';
import 'features/users/screens/add_user_screen.dart';
import 'features/sales/screens/add_sale_screen.dart';
import 'features/sales/screens/invoices_screen.dart';
import 'features/sales/screens/invoice_detail_screen.dart';
import 'features/inventory/screens/stock_screen.dart';
import 'features/inventory/screens/adjust_stock_screen.dart';
import 'features/inventory/screens/production_screen.dart';
import 'features/customers/screens/customers_list_screen.dart';
import 'features/customers/screens/add_customer_screen.dart';
import 'features/customers/screens/customer_ledger_screen.dart';
import 'features/suppliers/screens/suppliers_list_screen.dart';
import 'features/home/screens/all_services_screen.dart';

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
          page: () => const RawMaterialsListScreen(),
        ),
        GetPage(
          name: '/sales/new',
          page: () => const PlaceholderScreen(title: 'New Sale'),
        ),
        GetPage(name: '/sales/invoices', page: () => const InvoicesScreen()),
        GetPage(
          name: '/sales/invoices/:id/print',
          page: () {
            // Retrieve arguments passed via Get.toNamed
            // OR fetch if not passed (but detailed implementation relies on object for now)
            // For robustness, we can handle fetch in onInit of controller if we used one for detail
            // But passing argument is simplest for "Print after create"
            return InvoiceDetailScreen(sale: Get.arguments);
          },
        ),
        GetPage(name: '/inventory/stock', page: () => const StockScreen()),
        GetPage(
          name: '/inventory/production',
          page: () => const ProductionScreen(),
        ),
        GetPage(
          name: '/inventory/adjust-stock',
          page: () => const AdjustStockScreen(),
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
          page: () => const SuppliersListScreen(),
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
        GetPage(
          name: '/customers/:id/ledger',
          page: () => const CustomerLedgerScreen(),
        ),

        // All Services
        GetPage(name: '/all-services', page: () => const AllServicesScreen()),
      ],
    );
  }
}
