import 'package:get/get.dart';
import '../services/customer_service.dart';

class CustomerLedgerController extends GetxController {
  final CustomerService _service = CustomerService();

  final String customerId;
  CustomerLedgerController(this.customerId);

  var isLoading = true.obs;
  var ledgerData = <String, dynamic>{}.obs;

  // Payment
  var isProcessingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLedger();
  }

  Future<void> fetchLedger() async {
    isLoading.value = true;
    try {
      final data = await _service.getLedger(customerId);
      if (data != null) {
        ledgerData.value = data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load ledger');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> receivePayment(double amount, String note) async {
    isProcessingPayment.value = true;
    try {
      final success = await _service.receivePayment(customerId, amount, note);
      if (success) {
        Get.snackbar('Success', 'Payment received');
        fetchLedger(); // Refresh
        return true;
      } else {
        Get.snackbar('Error', 'Failed to record payment');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }
}
