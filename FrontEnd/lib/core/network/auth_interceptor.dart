import 'dart:async';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

import 'package:flutteractixapp/core/utils/user_agent.dart';
import 'package:flutteractixapp/features/auth/data/storage/token_storage.dart';

import 'package:flutteractixapp/core/router.dart' show router;
import 'package:flutter_dotenv/flutter_dotenv.dart';

typedef ClearToken = Future<void> Function();

class AuthInterceptor extends InterceptorContract {
  final TokenStorage tokenStorage;
  final String baseUrl;
  final ClearToken clearToken;

  AuthInterceptor({
    required this.tokenStorage,
    required this.baseUrl,
    required this.clearToken,
  });

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 👇 Añade la API Key de API Gateway (desde .env)
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      request.headers['x-api-key'] = apiKey;
    }

    request.headers['Accept'] = 'application/json';

    final userAgent = await getUserAgent();
    request.headers['X-User-Agent'] = userAgent;

    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    // Si el backend responde 401 => limpiar sesión y redirigir a login
    if (response.statusCode == 401) {
      await clearToken();
      // usa el go_router global
      // (asegúrate de que en tu router exista la ruta '/login')
      // Esto resetea el stack y va al login.
      router.go('/login');
    }
    return response;
  }
}
