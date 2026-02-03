import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../models/stock_item_model.dart';
import '../../products/models/product_model.dart';

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  final String _baseUrl =
      'https://black-diamond-server.vercel.app/api/inventory';
  // Assuming products are used for lookups too
  final String _productsUrl =
      'https://black-diamond-server.vercel.app/api/products';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // q is search query
  Future<List<StockItemModel>> getStock({String? q}) async {
    try {
      String url = '$_baseUrl/stock';
      if (q != null && q.isNotEmpty) {
        url += '?q=$q';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => StockItemModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching stock: $e');
      throw e;
    }
  }

  Future<bool> adjustStock({
    required String productId,
    required String type, // IN, OUT, ADJUST
    required double qtyChange,
    String? note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ledger'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'productId': productId,
          'type': type,
          'qtyChange': qtyChange,
          'note': note,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Try to parse JSON, if fails, it's likely HTML error
        try {
          final body = jsonDecode(response.body);
          print('Adjust Stock Failed: ${response.statusCode} ${response.body}');
          throw Exception(body['message'] ?? 'Failed to update stock');
        } on FormatException catch (_) {
          // It's not JSON (likely HTML)
          print('Server returned non-JSON response: ${response.body}');
          throw Exception(
            'Server Error: Endpoint not found or internal error (${response.statusCode})',
          );
        }
      }
    } catch (e) {
      print('Error adjusting stock: $e');
      rethrow;
    }
  }

  // Search Products for adjustment selection
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_productsUrl?q=$query'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming standard product response structure
        if (data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => ProductModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
