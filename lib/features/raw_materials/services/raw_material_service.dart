import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/raw_material_model.dart';

class RawMaterialService {
  static final RawMaterialService _instance = RawMaterialService._internal();
  factory RawMaterialService() => _instance;
  RawMaterialService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  Future<List<RawMaterialModel>> getRawMaterials() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/raw-materials'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => RawMaterialModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch raw materials: $e');
    }
  }

  Future<bool> createRawMaterial(RawMaterialModel material) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/raw-materials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(material.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create raw material: $e');
    }
  }

  Future<bool> updateRawMaterial(String id, RawMaterialModel material) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/raw-materials/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(material.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update raw material: $e');
    }
  }

  Future<bool> deleteRawMaterial(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/raw-materials/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
