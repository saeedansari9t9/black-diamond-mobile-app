import 'package:get/get.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierController extends GetxController {
  final SupplierService _service = SupplierService();

  var suppliers = <SupplierModel>[].obs;
  var isLoading = false.obs;

  // Ledger State
  var ledgerData = Rxn<Map<String, dynamic>>();
  var isLedgerLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    isLoading.value = true;
    try {
      final list = await _service.getSuppliers();
      suppliers.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load suppliers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSupplier(SupplierModel supplier) async {
    isLoading.value = true;
    try {
      final success = await _service.createSupplier(supplier);
      if (success) {
        await fetchSuppliers();
        Get.back(result: true);
        Get.snackbar('Success', 'Supplier created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create supplier');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSupplier(String id, SupplierModel supplier) async {
    isLoading.value = true;
    try {
      final success = await _service.updateSupplier(id, supplier);
      if (success) {
        await fetchSuppliers();
        Get.back(result: true);
        Get.snackbar('Success', 'Supplier updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update supplier');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      final success = await _service.deleteSupplier(id);
      if (success) {
        suppliers.removeWhere((s) => s.id == id);
        Get.snackbar('Success', 'Supplier deleted');
      } else {
        Get.snackbar('Error', 'Failed to delete supplier');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    }
  }

  Future<void> fetchLedger(String id) async {
    isLedgerLoading.value = true;
    try {
      final data = await _service.getLedger(id);
      ledgerData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load ledger: $e');
    } finally {
      isLedgerLoading.value = false;
    }
  }

  Future<void> paySupplier(String id, double amount, String note) async {
    isLedgerLoading.value = true;
    try {
      final success = await _service.paySupplier(id, amount, note);
      if (success) {
        await fetchLedger(id); // Refresh ledger
        Get.back(); // Close payment dialog
        Get.snackbar('Success', 'Payment recorded successfully');
      } else {
        Get.snackbar('Error', 'Failed to record payment');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLedgerLoading.value = false;
    }
  }
}
