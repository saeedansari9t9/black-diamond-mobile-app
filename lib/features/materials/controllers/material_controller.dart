import 'package:get/get.dart';
import '../models/material_model.dart';
import '../services/material_service.dart';

class MaterialController extends GetxController {
  final MaterialService _service = MaterialService();

  var materials = <MaterialModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    isLoading.value = true;
    try {
      final list = await _service.getMaterials();
      materials.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load materials: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMaterial(MaterialModel material) async {
    isLoading.value = true;
    try {
      final success = await _service.createMaterial(material);
      if (success) {
        await fetchMaterials();
        Get.back(result: true);
        Get.snackbar('Success', 'Material created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create material');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMaterial(String id, MaterialModel material) async {
    isLoading.value = true;
    try {
      final success = await _service.updateMaterial(id, material);
      if (success) {
        await fetchMaterials();
        Get.back(result: true);
        Get.snackbar('Success', 'Material updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update material');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      final success = await _service.deleteMaterial(id);
      if (success) {
        materials.removeWhere((m) => m.id == id);
        Get.snackbar('Success', 'Material deleted');
      } else {
        Get.snackbar('Error', 'Failed to delete material');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    }
  }
}
