import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  final UserService _service = UserService();

  var users = <UserModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers({String? query}) async {
    isLoading.value = true;
    try {
      final list = await _service.getUsers(query: query);
      users.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(UserModel user, String password) async {
    isLoading.value = true;
    try {
      final success = await _service.createUser(user, password);
      if (success) {
        await fetchUsers();
        Get.back(result: true);
        Get.snackbar('Success', 'User created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create user');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleUserStatus(UserModel user) async {
    // Optimistic Update
    final originalStatus = user.isActive;
    try {
      user.isActive = !user.isActive;
      users.refresh(); // Update UI

      final success = await _service.updateUserStatus(user.id!, user.isActive);
      if (!success) {
        // Revert
        user.isActive = originalStatus;
        users.refresh();
        Get.snackbar('Error', 'Failed to update status');
      }
    } catch (e) {
      // Revert
      user.isActive = originalStatus;
      users.refresh();
      Get.snackbar('Error', 'Error: $e');
    }
  }
}
