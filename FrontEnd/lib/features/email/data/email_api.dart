// lib/features/email/data/email_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailApi {
  final String bffUrl;
  final String? apiKey;
  final http.Client _http;

  EmailApi._(this.bffUrl, this.apiKey, this._http);

  factory EmailApi({http.Client? client}) {
    final raw = dotenv.env['BFF_URL'] ?? '';
    if (raw.isEmpty) {
      throw StateError('BFF_URL no definido en .env');
    }
    final normalized = raw.replaceAll(RegExp(r'/+$'), '');
    final apiKey = dotenv.env['BFF_API_KEY'];
    return EmailApi._(normalized, apiKey, client ?? http.Client());
  }

  /// GET {BFF_URL}/health  → "ok"
  Future<bool> health({Duration timeout = const Duration(seconds: 8)}) async {
    final uri = Uri.parse('$bffUrl/health');
    final headers = <String, String>{};
    if (apiKey != null && apiKey!.isNotEmpty) {
      headers['x-api-key'] = apiKey!;
    }
    final resp = await _http.get(uri, headers: headers).timeout(timeout);
    return resp.statusCode == 200 && resp.body.trim().toLowerCase() == 'ok';
  }

  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    // Validación mínima
    if (to.trim().isEmpty || !to.contains('@')) {
      throw ArgumentError.value(to, 'to', 'Correo inválido');
    }

    final uri = Uri.parse('$bffUrl/notify/email');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (apiKey != null && apiKey!.isNotEmpty) {
      headers['x-api-key'] = apiKey!;
    }

    http.Response resp;
    try {
      resp = await _http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({'to': to, 'subject': subject, 'body': body}),
          )
          .timeout(timeout);
    } on SocketException {
      throw Exception('No hay conexión a Internet o DNS falló');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException {
      throw Exception('Respuesta no válida del servidor');
    }

    // OK / Accepted / Created
    if (resp.statusCode == 200 || resp.statusCode == 201 || resp.statusCode == 202) {
      return;
    }

    // Errores comunes con pistas útiles
    if (resp.statusCode == 401) {
      throw Exception('401 Unauthorized: revisa autenticación del BFF');
    }
    if (resp.statusCode == 403) {
      throw Exception(
        '403 Forbidden: verifica que BFF_API_KEY esté asociado al Usage Plan y al stage correcto.',
      );
    }

    // Intenta extraer {code,message} del backend
    try {
      final data = jsonDecode(resp.body);
      final code = data['code'] ?? 'UNKNOWN';
      final msg = data['message'] ?? resp.body;
      throw Exception('BFF ${resp.statusCode} [$code]: $msg');
    } catch (_) {
      throw Exception('BFF ${resp.statusCode}: ${resp.body}');
    }
  }
}
