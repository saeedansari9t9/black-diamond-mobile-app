import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  final _box = GetStorage();
  final String _tokenKey = 'auth_token';

  String? get _token => _box.read(_tokenKey);

  Future<String?> getToken() async {
    return _token;
  }

  String get userName => _box.read('user_name') ?? 'Guest';
  String get userEmail => _box.read('user_email') ?? '';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print(
        'Login Response: ${response.statusCode} ${response.body}',
      ); // DEBUG LOG

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String? token;
        if (data['token'] != null) {
          token = data['token'];
        } else if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'];
        }

        if (token != null) {
          await _box.write(_tokenKey, token);

          // Store user info if available
          if (data['data'] != null && data['data']['user'] != null) {
            final user = data['data']['user'];
            await _box.write('user_name', user['name'] ?? 'User');
            await _box.write('user_email', user['email'] ?? '');
          }

          print('Token stored: $token'); // DEBUG LOG
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<void> logout() async {
    await _box.remove(_tokenKey);
    await _box.remove('user_name');
    await _box.remove('user_email');
  }
}
