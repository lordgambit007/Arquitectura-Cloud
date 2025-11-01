import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_interceptor.dart';
import 'api_key_interceptor.dart';
import 'package:flutteractixapp/features/auth/data/storage/token_storage.dart';

/// Cliente HTTP con inicialización perezosa.
/// - Lee BASE_URL (y API_KEY dentro del interceptor) **después** de que .env esté cargado.
/// - Reutiliza un solo cliente para toda la app.
class HttpClient {
  final TokenStorage _tokenStorage;

  // Cliente compartido para toda la app (singleton simple).
  static InterceptedClient? _shared;

  HttpClient({
    required TokenStorage tokenStorage,
  }) : _tokenStorage = tokenStorage;

  /// Obtén el cliente listo para usar. Si aún no existe, lo crea.
  http.Client get client {
    if (_shared == null) {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';

      // Sugerencia: falla rápido si falta BASE_URL
      if (baseUrl.isEmpty) {
        throw StateError(
          'BASE_URL no está definido. Asegúrate de cargar .env en main() antes de usar HttpClient.',
        );
      }

      _shared = InterceptedClient.build(
        interceptors: [
          // Si tu ApiKeyInterceptor lee dotenv internamente, ahora sí tendrá valores
          // porque este bloque se ejecuta después de cargar .env.
          ApiKeyInterceptor(),
          AuthInterceptor(
            tokenStorage: _tokenStorage,
            baseUrl: baseUrl,
            clearToken: _tokenStorage.deleteTokens,
          ),
        ],
        // Puedes ajustar el timeout si lo necesitas
        requestTimeout: const Duration(seconds: 30),
      );
    }
    return _shared!;
  }
}
