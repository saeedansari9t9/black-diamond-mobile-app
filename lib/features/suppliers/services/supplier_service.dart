import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier_model.dart';

class SupplierService {
  static final SupplierService _instance = SupplierService._internal();
  factory SupplierService() => _instance;
  SupplierService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/suppliers'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => SupplierModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch suppliers: $e');
    }
  }

  Future<bool> createSupplier(SupplierModel supplier) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/suppliers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplier.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  Future<bool> updateSupplier(String id, SupplierModel supplier) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/suppliers/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplier.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/suppliers/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Returns a Map with { supplier, totalDue, unpaidPurchases, payments }
  Future<Map<String, dynamic>?> getLedger(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/suppliers/$id/ledger'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch ledger: $e');
    }
  }

  Future<bool> paySupplier(String id, double amount, String note) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/suppliers/$id/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'note': note,
          'date': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to pay supplier: $e');
    }
  }
}
