import 'package:dio/dio.dart';

/// BE (AuthController) trả token qua cookie HttpOnly cho web và đặt
/// accessToken/refreshToken trong body = null. App mobile không dùng cookie
/// nên đọc token từ header Set-Cookie của response login/refresh.
class TokenCookies {
  TokenCookies._();

  static const String accessCookie = 'phimium_access';
  static const String refreshCookie = 'phimium_refresh';

  /// Trả về {tên cookie: giá trị} lấy từ các header Set-Cookie
  static Map<String, String> read(Headers headers) {
    final result = <String, String>{};
    for (final raw in headers['set-cookie'] ?? const <String>[]) {
      final pair = raw.split(';').first;
      final idx = pair.indexOf('=');
      if (idx <= 0) continue;
      final name = pair.substring(0, idx).trim();
      final value = pair.substring(idx + 1).trim();
      if (value.isNotEmpty) result[name] = value;
    }
    return result;
  }

  /// Lấy token: ưu tiên body, nếu rỗng thì lấy từ cookie
  static ({String access, String refresh}) fromResponse(
    Response response,
    Map<String, dynamic>? data,
  ) {
    final cookies = read(response.headers);
    String pick(String? body, String cookieName) =>
        (body != null && body.isNotEmpty && body != 'null') ? body : (cookies[cookieName] ?? '');
    return (
      access: pick(data?['accessToken']?.toString(), accessCookie),
      refresh: pick(data?['refreshToken']?.toString(), refreshCookie),
    );
  }
}
