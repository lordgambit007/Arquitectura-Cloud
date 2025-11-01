import 'dart:convert';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (kDebugMode) {
      debugPrint('➡️  ${request.method} ${request.url}');
      if (request is Request && request.body.isNotEmpty) {
        debugPrint('➡️  Body: ${request.body}');
      }
      debugPrint('➡️  Headers: ${request.headers}');
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    if (kDebugMode) {
      debugPrint('⬅️  ${response.request?.method} ${response.request?.url} '
          '→ ${response.statusCode}');
      if (response is Response) {
        final text = response.body;
        if (text.isNotEmpty) {
          // recorta para no inundar logs
          debugPrint('⬅️  Body: ${text.length > 1200 ? text.substring(0,1200)+' ...' : text}');
        } else {
          debugPrint('⬅️  (sin cuerpo)');
        }
      }
    }
    return response;
  }
}
