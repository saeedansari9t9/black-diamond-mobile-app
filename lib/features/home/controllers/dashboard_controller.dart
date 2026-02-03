import 'package:get/get.dart';
import '../../sales/services/sales_service.dart';
import '../../customers/services/customer_service.dart';
import '../../suppliers/services/supplier_service.dart';

class DashboardController extends GetxController {
  final _salesService = SalesService();
  final _customerService = CustomerService();
  final _supplierService = SupplierService();

  var totalSales = 0.0.obs;
  var totalOrders = 0.obs;
  var totalCustomers = 0.obs;
  var totalSuppliers = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      // 1. Fetch Sales for Current Month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(
        now.year,
        now.month + 1,
        0,
        23,
        59,
        59,
      ); // Last day of month

      final sales = await _salesService.getSales(
        from: startOfMonth,
        to: endOfMonth,
      );

      totalOrders.value = sales.length;
      totalSales.value = sales.fold(0.0, (sum, sale) => sum + sale.grandTotal);

      // 2. Fetch Customers
      final customers = await _customerService.getCustomers();
      totalCustomers.value = customers.length;

      // 3. Fetch Suppliers
      final suppliers = await _supplierService.getSuppliers();
      totalSuppliers.value = suppliers.length;
    } catch (e) {
      print('Error loading stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
