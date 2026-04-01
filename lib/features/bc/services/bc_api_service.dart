import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bc_models.dart';

class BcApiService {
  static const String baseUrl = 'https://black-diamond-server.vercel.app/api/bc';

  // Helper method to handle responses
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else {
      String errorMessage = 'An error occurred';
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          if (decoded.containsKey('message')) {
            errorMessage = decoded['message'].toString();
          } else if (decoded.containsKey('error')) {
            errorMessage = decoded['error'].toString();
          }
        }
      } catch (_) {
        errorMessage = response.statusCode.toString();
      }
      throw errorMessage;
    }
  }

  Future<BcDashboardModel> getDashboard() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard'));
    final data = _processResponse(response);
    return BcDashboardModel.fromJson(data);
  }

  Future<void> updateSettings(num monthlyContribution) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'monthlyContribution': monthlyContribution}),
    );
    _processResponse(response);
  }

  Future<List<BcMemberModel>> getMembers() async {
    final response = await http.get(Uri.parse('$baseUrl/members'));
    final data = _processResponse(response) as List;
    return data.map((e) => BcMemberModel.fromJson(e)).toList();
  }

  Future<void> addMembers(List<String> names) async {
    final response = await http.post(
      Uri.parse('$baseUrl/members'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'names': names}),
    );
    _processResponse(response);
  }

  Future<void> deleteMember(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/members/$id'));
    _processResponse(response);
  }

  Future<BcMonthDataModel> getMonthData(int monthNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/months/$monthNumber'));
    final data = _processResponse(response);
    return BcMonthDataModel.fromJson(data);
  }

  Future<void> togglePaymentStatus(String recordId) async {
    final response = await http.put(Uri.parse('$baseUrl/records/$recordId/toggle'));
    _processResponse(response);
  }

  Future<void> selectWinner(int month, String winnerId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/months/$month/payout'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'winnerId': winnerId}),
    );
    _processResponse(response);
  }

  Future<void> completeMonth(int month) async {
    final response = await http.put(
      Uri.parse('$baseUrl/months/$month/complete'),
    );
    _processResponse(response);
  }
}
