import 'package:get/get.dart';
import '../models/stock_item_model.dart';
import '../services/inventory_service.dart';
import '../../products/models/product_model.dart';

class InventoryController extends GetxController {
  final InventoryService _service = InventoryService();

  var stockList = <StockItemModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  // For Adjustment
  var productSearchResults = <ProductModel>[].obs;
  var isSearchingProducts = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStock();

    // Debounce search
    debounce(
      searchQuery,
      (_) => fetchStock(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> fetchStock() async {
    isLoading.value = true;
    try {
      final list = await _service.getStock(q: searchQuery.value);
      stockList.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load stock: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchProductsForAdjustment(String query) async {
    isSearchingProducts.value = true;
    try {
      final list = await _service.searchProducts(query);
      productSearchResults.assignAll(list);
    } finally {
      isSearchingProducts.value = false;
    }
  }

  Future<bool> adjustStock({
    required String productId,
    required String type, // IN, OUT, ADJUST
    required double qty,
    String? note,
  }) async {
    // Basic validation
    if (qty <= 0) {
      Get.snackbar('Error', 'Quantity must be greater than 0');
      return false;
    }

    // Backend expects signed qtyChange?
    // User request: "qtyChange(number) required". + for IN, - for OUT.
    // Logic:
    // IN: +qty
    // OUT: -qty
    // ADJUST: depends? Usually user enters difference or correct amt.
    // The snippet says: "qtyChange".

    double change = qty;
    if (type == 'OUT') {
      change = -qty;
    }
    // ADJUST implies adding delta? Or setting absolute?
    // The snippet: "$sum: $moves.qtyChange". So it's delta based.
    // If type is ADJUST, does the backend handle it specially?
    // Code: "addStockEntry... type... qtyChange".
    // It just logs it. "qty" field in schema stores it.
    // So if user selects 'ADJUST', they probably mean "Correction".
    // Usually correction means "Add this much" or "Remove this much" to fix it.
    // Let's stick to IN (+) and OUT (-).
    // If UI has 'ADJUST', maybe treat as + or - depending on sign input?
    // Let's assume Type is for logging 'refType' or similar, but 'qtyChange' drives the stock.
    // The backend stores `type` (IN, OUT, ADJUST).
    // And `qtyChange` is what modifies the sum.

    // So if I select OUT and enter 5, I should send -5?
    // Yes usually.

    isLoading.value = true;
    try {
      final success = await _service.adjustStock(
        productId: productId,
        type: 'adjust', // Backend expects 'adjust' for manual moves
        qtyChange: change,
        note: note,
      );

      if (success) {
        Get.snackbar('Success', 'Stock updated');
        fetchStock(); // Refresh list
        return true;
      }
    } catch (e) {
      String msg = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar('Error', msg);
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}
