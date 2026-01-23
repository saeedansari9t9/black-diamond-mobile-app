import 'package:get/get.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerController extends GetxController {
  final CustomerService _service = CustomerService();

  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers({String? query}) async {
    isLoading.value = true;
    try {
      final list = await _service.getCustomers(query: query);
      customers.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load customers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCustomer(CustomerModel customer) async {
    isLoading.value = true;
    try {
      final success = await _service.createCustomer(customer);
      if (success) {
        await fetchCustomers();
        Get.back(result: true);
        Get.snackbar('Success', 'Customer created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create customer');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
