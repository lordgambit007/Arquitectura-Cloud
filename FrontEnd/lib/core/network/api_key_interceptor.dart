import 'package:http_interceptor/http_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Agrega el encabezado x-api-key a TODAS las requests.
class ApiKeyInterceptor implements InterceptorContract {
  final String _apiKey = (dotenv.env['API_KEY'] ?? '').trim();

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (_apiKey.isNotEmpty) {
      request.headers['x-api-key'] = _apiKey;
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    // No modificamos la respuesta
    return response;
  }

  @override
  bool shouldInterceptRequest() => true;

  @override
  bool shouldInterceptResponse() => true;
}
