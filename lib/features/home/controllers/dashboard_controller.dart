import 'package:get/get.dart';
import '../../sales/services/sales_service.dart';
import '../../sales/models/sale_model.dart'; // Import SaleModel
import '../../customers/services/customer_service.dart';
import '../../suppliers/services/supplier_service.dart';

class DashboardController extends GetxController {
  final _salesService = SalesService();
  final _customerService = CustomerService();
  final _supplierService = SupplierService();

  // Monthly Stats
  var monthlySalesTotal = 0.0.obs; // Renamed for clarity
  var monthlyOrders = 0.obs;

  // Today's Stats
  var todaySalesTotal = 0.0.obs;
  var todayOrders = 0.obs;
  var todaySalesList = <SaleModel>[].obs;

  var totalCustomers = 0.obs;
  var totalSuppliers = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchStats(); // Moved to onReady to avoid blocking initial UI build
  }

  @override
  void onReady() {
    super.onReady();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final results = await Future.wait([
        _salesService.getSales(
          from: startOfMonth,
          to: endOfDay,
        ), // 0. Monthly Data
        _salesService.getSales(from: startOfDay, to: endOfDay), // 1. Today Data
        _customerService.getCustomers(), // 2. Customers
        _supplierService.getSuppliers(), // 3. Suppliers
      ]);

      // 1. Process Monthly Stats (Calculate locally)
      final rawMonthList = results[0] as List;
      final monthList = rawMonthList.cast<SaleModel>();

      double mTotal = 0;
      for (var sale in monthList) {
        mTotal += sale.grandTotal;
      }
      monthlySalesTotal.value = mTotal;
      monthlyOrders.value = monthList.length;

      // 2. Process Today's Stats (Calculate locally)
      final rawTodayList = results[1] as List;
      final todayList = rawTodayList.cast<SaleModel>();

      double tTotal = 0;
      for (var sale in todayList) {
        tTotal += sale.grandTotal;
      }
      todaySalesTotal.value = tTotal;
      todayOrders.value = todayList.length;

      // 3. Update Dashboard List (Limited to 20)
      todaySalesList.assignAll(todayList.reversed.take(20).toList());

      // 4. Customers
      final customers = results[2] as List;
      totalCustomers.value = customers.length;

      // 5. Suppliers
      final suppliers = results[3] as List;
      totalSuppliers.value = suppliers.length;
    } catch (e) {
      print('Error loading stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
