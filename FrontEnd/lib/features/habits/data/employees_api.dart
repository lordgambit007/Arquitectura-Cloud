// lib/features/habits/data/employees_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutteractixapp/features/auth/data/storage/token_storage.dart';

class EmployeesApi {
  final String baseUrl;
  final TokenStorage tokenStorage;

  EmployeesApi({
    required this.baseUrl,
    required this.tokenStorage,
  });

  /// Headers dinámicos: incluye Bearer y X-API-Key (necesario en API Gateway).
  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.getAccessToken();
    final apiKey = dotenv.env['API_KEY'] ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (apiKey.isNotEmpty) 'x-api-key': apiKey,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      // Opcional: útil para logs del backend
      'X-User-Agent': 'appVersion=1.0.0; os=android; isMobile=true',
    };
  }

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  /// GET /employees
  Future<List<Map<String, dynamic>>> list() async {
    final res = await http
        .get(_u('/employees'), headers: await _headers())
        .timeout(const Duration(seconds: 20));

    if (kDebugMode) {
      debugPrint('↗️ GET $baseUrl/employees → ${res.statusCode}');
      debugPrint('↙️ Body: ${res.body}');
    }

    if (res.statusCode == 200) {
      if (res.body.isEmpty) return [];
      final decoded = json.decode(res.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      if (decoded is Map && decoded['employees'] is List) {
        return (decoded['employees'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      throw const FormatException('Formato inesperado en respuesta de empleados');
    }

    if (res.statusCode == 204) return [];
    if (res.statusCode == 401) {
      throw Exception('No autorizado (401): revisa el token');
    }
    if (res.statusCode == 403) {
      throw Exception('Forbidden (403): agrega/valida la x-api-key en headers');
    }

    throw Exception('list ${res.statusCode}: ${res.body}');
  }

  /// POST /employees
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await http
        .post(_u('/employees'), headers: await _headers(), body: json.encode(data))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 200 || res.statusCode == 201) {
      return res.body.isEmpty ? <String, dynamic>{} : json.decode(res.body);
    }
    if (res.statusCode == 403) {
      throw Exception('Forbidden (403): falta/incorrecta x-api-key');
    }
    throw Exception('create ${res.statusCode}: ${res.body}');
  }

  /// PUT /employees/:id
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> patch) async {
    final res = await http
        .put(_u('/employees/$id'), headers: await _headers(), body: json.encode(patch))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 200) {
      return res.body.isEmpty ? <String, dynamic>{} : json.decode(res.body);
    }
    if (res.statusCode == 403) {
      throw Exception('Forbidden (403): falta/incorrecta x-api-key');
    }
    throw Exception('update ${res.statusCode}: ${res.body}');
  }

  /// DELETE /employees/:id
  Future<void> delete(String id) async {
    final res = await http
        .delete(_u('/employees/$id'), headers: await _headers())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 200 || res.statusCode == 204) return;
    if (res.statusCode == 403) {
      throw Exception('Forbidden (403): falta/incorrecta x-api-key');
    }
    throw Exception('delete ${res.statusCode}: ${res.body}');
  }
}
