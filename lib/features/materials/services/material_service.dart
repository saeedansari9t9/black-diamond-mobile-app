import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/material_model.dart';

class MaterialService {
  static final MaterialService _instance = MaterialService._internal();
  factory MaterialService() => _instance;
  MaterialService._internal();

  final String _baseUrl = 'https://black-diamond-server.vercel.app/api';

  Future<List<MaterialModel>> getMaterials() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/materials'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((e) => MaterialModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch materials: $e');
    }
  }

  Future<bool> createMaterial(MaterialModel material) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/materials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(material.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create material: $e');
    }
  }

  Future<bool> updateMaterial(String id, MaterialModel material) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/materials/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(material.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update material: $e');
    }
  }

  Future<bool> deleteMaterial(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/materials/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
