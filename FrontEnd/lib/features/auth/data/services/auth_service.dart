// lib/features/auth/data/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutteractixapp/core/messages/errors/data_error.dart' as core_errors;
import 'package:flutteractixapp/core/utils/user_agent.dart';
import 'package:flutteractixapp/features/auth/data/errors/data_error.dart' as auth_errors;
import 'package:flutteractixapp/features/auth/data/storage/token_storage.dart';

class AuthService {
  final String baseUrl;
  final TokenStorage tokenStorage;

  AuthService({required this.baseUrl, required this.tokenStorage});

  Future<void> refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      throw auth_errors.RefreshTokenNotFoundError();
    }

    final url = Uri.parse('$baseUrl/auth/refresh-token');
    final userAgent = await getUserAgent();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Agent': userAgent,
      },
      body: json.encode({'refresh_token': refreshToken}),
    );

    final bodyRaw = response.body;
    final decoded = bodyRaw.isEmpty ? null : json.decode(bodyRaw);
    final responseCode = (decoded is Map && decoded['code'] is String)
        ? decoded['code'] as String
        : null;

    if (response.statusCode == 200) {
      final newAccessToken = decoded['access_token'] as String;
      final newRefreshToken = decoded['refresh_token'] as String;
      await tokenStorage.saveTokens(newAccessToken, newRefreshToken);
      return;
    }

    // Limpia tokens si falla
    await tokenStorage.deleteTokens();

    if (response.statusCode == 401) {
      if (responseCode == 'REFRESH_TOKEN_EXPIRED') {
        throw auth_errors.RefreshTokenExpiredError();
      } else if (responseCode == 'INVALID_REFRESH_TOKEN') {
        throw auth_errors.InvalidRefreshTokenError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }
}
