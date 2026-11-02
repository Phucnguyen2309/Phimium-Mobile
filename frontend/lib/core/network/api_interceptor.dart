import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import 'token_cookies.dart';

/// Gắn access token vào request và tự refresh khi gặp 401
class ApiInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (kIsWeb) {
      options.extra['withCredentials'] = true;
      handler.next(options);
      return;
    }
    final token = await _storage.read(key: StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRefreshCall = err.requestOptions.path.contains(ApiConstants.refreshToken);
    if (err.response?.statusCode == 401 && !isRefreshCall) {
      if (kIsWeb) {
        try {
          final dio = Dio(
            BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              extra: {'withCredentials': true},
            ),
          );
          try {
            (dio.httpClientAdapter as dynamic).withCredentials = true;
          } catch (_) {}
          await dio.post(ApiConstants.refreshToken);
          err.requestOptions.extra['withCredentials'] = true;
          final retryResponse = await dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          return handler.next(err);
        }
      }

      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
          final response = await dio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          // BE trả về ApiResponse<LoginResponse> => { success, code, message, data: {...} }
          final data = response.data is Map ? response.data['data'] : null;
          final tokens = TokenCookies.fromResponse(
            response,
            data is Map ? Map<String, dynamic>.from(data) : null,
          );
          final newToken = tokens.access;
          if (newToken.isNotEmpty) {
            await _storage.write(key: StorageKeys.accessToken, value: newToken);
            if (tokens.refresh.isNotEmpty) {
              await _storage.write(key: StorageKeys.refreshToken, value: tokens.refresh);
            }

            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await _storage.deleteAll();
        }
      }
    }
    handler.next(err);
  }
}
