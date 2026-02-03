import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../models/customer_model.dart';

class CustomerService {
  // Singleton
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CustomerModel>> getCustomers({String? query}) async {
    try {
      String url = '$_baseUrl/customers?';
      if (query != null && query.isNotEmpty) url += 'q=$query&';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => CustomerModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  Future<bool> createCustomer(CustomerModel customer) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: await _getHeaders(),
        body: jsonEncode(customer.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  // Get Ledger Data
  Future<Map<String, dynamic>?> getLedger(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers/$id/ledger'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Failed to fetch customer ledger: $e');
      return null; // Return null instead of throwing to handle UI gracefully
    }
  }

  // Receive Payment
  Future<bool> receivePayment(String id, double amount, String note) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers/$id/payment'),
        headers: await _getHeaders(),
        body: jsonEncode({'amount': amount, 'note': note}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to record payment: $e');
    }
  }
}
