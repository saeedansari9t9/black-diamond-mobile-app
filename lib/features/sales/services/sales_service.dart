import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../models/sale_model.dart';

class SalesService {
  static final SalesService _instance = SalesService._internal();
  factory SalesService() => _instance;
  SalesService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<SaleModel?> createSale(SaleModel sale) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sales'),
        headers: await _getHeaders(),
        body: jsonEncode(sale.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          return SaleModel.fromJson(data['data']);
        }
      } else {
        // Debug Log
        print('Create Sale Failed: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      return null;
    } catch (e) {
      print('Exception in createSale: $e');
      return null;
    }
  }

  // Fetch Single Sale Detail
  Future<SaleModel?> getSaleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sales/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          return SaleModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch sale detail: $e');
      return null;
    }
  }

  Future<List<SaleModel>> getSales({DateTime? from, DateTime? to}) async {
    try {
      String url = '$_baseUrl/sales?';
      if (from != null) url += 'from=${from.toIso8601String()}&';
      if (to != null) url += 'to=${to.toIso8601String()}&';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => SaleModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sales: $e');
    }
  }
}
