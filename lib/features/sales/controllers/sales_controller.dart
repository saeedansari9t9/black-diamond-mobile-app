import 'package:get/get.dart';
import '../models/sale_model.dart';
import '../services/sales_service.dart';
import '../../products/models/product_model.dart';

class SalesController extends GetxController {
  final SalesService _service = SalesService();

  // Cart State
  var cartItems = <SaleItemModel>[].obs;

  // Sale Details
  var selectedCustomerName = 'Walk-in'.obs;
  var selectedCustomerId = RxnString(); // Nullable
  var discount = 0.0.obs;
  var paidAmount = 0.0.obs;
  var paymentMethod = 'cash'.obs;
  var note = ''.obs;

  var isLoading = false.obs;

  // Invoices / History State
  var sales = <SaleModel>[].obs;
  var searchInvoice = ''.obs;
  var searchCustomer = ''.obs;
  var customerTypeFilter = 'all'.obs; // 'all', 'walkin', 'regular'
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  // Computed Properties
  double get subTotal => cartItems.fold(0, (sum, item) => sum + item.lineTotal);
  double get grandTotal =>
      (subTotal - discount.value).clamp(0, double.infinity);
  double get dueAmount =>
      (grandTotal - paidAmount.value).clamp(0, double.infinity);

  @override
  void onInit() {
    super.onInit();
    // Load initial sales (e.g. today or last 30 days if preferred, or all)
    fetchSales();
  }

  // Fetch Sales (Invoices)
  Future<void> fetchSales() async {
    isLoading.value = true;
    try {
      final list = await _service.getSales(
        from: fromDate.value,
        to: toDate.value,
      );
      sales.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sales: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Client-side Filtering
  List<SaleModel> get filteredSales {
    return sales.where((sale) {
      final invMatch = (sale.invoiceNo ?? '').toLowerCase().contains(
        searchInvoice.value.toLowerCase(),
      );
      final custName = sale.customerName ?? 'Walk-in';
      final custMatch = custName.toLowerCase().contains(
        searchCustomer.value.toLowerCase(),
      );

      final isWalkIn = custName.toLowerCase() == 'walk-in';
      bool typeMatch = true;
      if (customerTypeFilter.value == 'walkin') typeMatch = isWalkIn;
      if (customerTypeFilter.value == 'regular') typeMatch = !isWalkIn;

      return invMatch && custMatch && typeMatch;
    }).toList();
  }

  void addItem(ProductModel product) {
    // Check if item already exists
    final index = cartItems.indexWhere((item) => item.productId == product.id);

    if (index >= 0) {
      // Update quantity
      final existing = cartItems[index];
      updateItem(index, existing.qty + 1, existing.price);
    } else {
      // Add new item
      cartItems.add(
        SaleItemModel(
          productId: product.id!,
          productName: product.name,
          qty: 1,
          price: product.retailPrice != null
              ? product.retailPrice!.toDouble()
              : 0.0,
          lineTotal: product.retailPrice != null
              ? product.retailPrice!.toDouble()
              : 0.0,
        ),
      );
    }
  }

  void updateItem(int index, double qty, double price) {
    if (index < 0 || index >= cartItems.length) return;

    final oldItem = cartItems[index];
    final newItem = SaleItemModel(
      productId: oldItem.productId,
      productName: oldItem.productName,
      qty: qty,
      price: price,
      lineTotal: qty * price,
    );

    cartItems[index] = newItem;
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }

  void clearCart() {
    cartItems.clear();
    discount.value = 0;
    paidAmount.value = 0;
    paymentMethod.value = 'cash';
    note.value = '';
    selectedCustomerName.value = 'Walk-in';
    selectedCustomerId.value = null;
  }

  Future<SaleModel?> submitSale() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return null;
    }

    isLoading.value = true;
    try {
      final sale = SaleModel(
        customerId: selectedCustomerId.value,
        customerName: selectedCustomerName.value,
        saleType: 'retail', // Default
        items: cartItems.toList(),
        subTotal: subTotal,
        discount: discount.value,
        grandTotal: grandTotal,
        paymentMethod: paymentMethod.value,
        paidAmount: paidAmount.value,
        dueAmount: dueAmount,
        note: note.value,
      );

      final createdSale = await _service.createSale(sale);

      if (createdSale != null) {
        clearCart();
        await fetchSales(); // Refresh list to get the new invoice
        Get.back(); // Close AddSaleScreen
        Get.snackbar('Success', 'Sale created successfully');

        // Navigate to Invoice Detail / Print Screen
        // We'll implement this screen next
        Get.toNamed(
          '/sales/invoices/${createdSale.id}/print',
          arguments: createdSale,
        );
        return createdSale; // Return the created sale
      } else {
        Get.snackbar('Error', 'Failed to create sale');
        return null; // Ensure return matches type signature
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
