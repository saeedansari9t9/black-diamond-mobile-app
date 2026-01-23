import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  Future<List<ProductModel>> getProducts({String? query}) async {
    try {
      String url = '$_baseUrl/products';
      if (query != null && query.isNotEmpty) {
        url += '?q=$query';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => ProductModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<bool> createProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<bool> updateProduct(String id, ProductModel product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
