import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import 'api_interceptor.dart';

/// Dio HTTP Client configuration
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        extra: kIsWeb ? {'withCredentials': true} : const {},
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kIsWeb) {
      try {
        (_dio.httpClientAdapter as dynamic).withCredentials = true;
      } catch (_) {}
    }

    _dio.interceptors.add(ApiInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  /// Uu tien: --dart-define=API_BASE_URL > file .env > tu dong theo nen tang
  static String _resolveBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromEnv = dotenv.isInitialized ? dotenv.maybeGet('API_BASE_URL') : null;
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return 'http://localhost:8080';
    }
    return ApiConstants.baseUrl;
  }
}
