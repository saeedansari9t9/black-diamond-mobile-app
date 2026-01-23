import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _service = ProductService();

  var products = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({String? query}) async {
    isLoading.value = true;
    try {
      final list = await _service.getProducts(query: query);
      products.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProduct(ProductModel product, {int? initialStock}) async {
    isLoading.value = true;
    try {
      // Assuming createProduct returns success boolean
      final success = await _service.createProduct(product);
      if (success) {
        await fetchProducts();
        Get.back(result: true);
        Get.snackbar('Success', 'Product created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create product');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(String id, ProductModel product) async {
    isLoading.value = true;
    try {
      final success = await _service.updateProduct(id, product);
      if (success) {
        await fetchProducts();
        Get.back(result: true);
        Get.snackbar('Success', 'Product updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update product');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final success = await _service.deleteProduct(id);
      if (success) {
        products.removeWhere((p) => p.id == id);
        Get.snackbar('Success', 'Product deleted');
      } else {
        Get.snackbar('Error', 'Failed to delete product');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    }
  }
}
