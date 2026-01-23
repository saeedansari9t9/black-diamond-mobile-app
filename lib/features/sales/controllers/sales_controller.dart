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

  // Computed Properties
  double get subTotal => cartItems.fold(0, (sum, item) => sum + item.lineTotal);
  double get grandTotal =>
      (subTotal - discount.value).clamp(0, double.infinity);
  double get dueAmount =>
      (grandTotal - paidAmount.value).clamp(0, double.infinity);

  void addItem(ProductModel product) {
    // Check if item already exists
    final index = cartItems.indexWhere((item) => item.productId == product.id);

    if (index >= 0) {
      // Update quantity
      final existing = cartItems[index];
      updateItem(index, existing.qty + 1, existing.price);
    } else {
      // Add new item
      // Default price logic: if product has retailPrice, use it.
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

  Future<void> submitSale() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return;
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

      final success = await _service.createSale(sale);
      if (success) {
        clearCart();
        Get.back();
        Get.snackbar('Success', 'Sale created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create sale');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
