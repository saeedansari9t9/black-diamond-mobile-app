import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../auth/services/auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  // Helper to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<UserModel>> getUsers({String? query, String? role}) async {
    try {
      String url = '$_baseUrl/users?';
      if (query != null && query.isNotEmpty) url += 'q=$query&';
      if (role != null && role.isNotEmpty) url += 'role=$role&';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          final users = list.map((e) => UserModel.fromJson(e)).toList();
          if (users.isNotEmpty) return users;
        }
      }
      // If empty or error, fall through to dummy data for now
      return _getDummyUsers();
    } catch (e) {
      // Fallback to dummy data on error
      return _getDummyUsers();
    }
  }

  List<UserModel> _getDummyUsers() {
    return [
      UserModel(
        id: '1',
        name: 'Admin User',
        email: 'admin@bd.com',
        role: 'admin',
        isActive: true,
      ),
      UserModel(
        id: '2',
        name: 'Sales Manager',
        email: 'sales@bd.com',
        role: 'manager',
        isActive: true,
      ),
      UserModel(
        id: '3',
        name: 'Inventory Clerk',
        email: 'stock@bd.com',
        role: 'inventory',
        isActive: true,
      ),
    ];
  }

  Future<bool> createUser(UserModel user, String password) async {
    try {
      final body = user.toJson();
      body['password'] = password;

      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<bool> updateUserStatus(String id, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/users/$id/status'),
        headers: await _getHeaders(),
        body: jsonEncode({'isActive': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
