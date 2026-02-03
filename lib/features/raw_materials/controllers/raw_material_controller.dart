import 'package:get/get.dart';
import '../models/raw_material_model.dart';
import '../services/raw_material_service.dart';

class RawMaterialController extends GetxController {
  final RawMaterialService _service = RawMaterialService();

  var rawMaterials = <RawMaterialModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRawMaterials();
  }

  Future<void> fetchRawMaterials() async {
    isLoading.value = true;
    try {
      final list = await _service.getRawMaterials();
      rawMaterials.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load raw materials: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRawMaterial(RawMaterialModel material) async {
    isLoading.value = true;
    try {
      final success = await _service.createRawMaterial(material);
      if (success) {
        await fetchRawMaterials();
        Get.back(result: true);
        Get.snackbar('Success', 'Raw material created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create raw material');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRawMaterial(String id, RawMaterialModel material) async {
    isLoading.value = true;
    try {
      final success = await _service.updateRawMaterial(id, material);
      if (success) {
        await fetchRawMaterials();
        Get.back(result: true);
        Get.snackbar('Success', 'Raw material updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update raw material');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRawMaterial(String id) async {
    try {
      final success = await _service.deleteRawMaterial(id);
      if (success) {
        rawMaterials.removeWhere((m) => m.id == id);
        Get.snackbar('Success', 'Raw material deleted');
      } else {
        Get.snackbar('Error', 'Failed to delete raw material');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    }
  }
}
