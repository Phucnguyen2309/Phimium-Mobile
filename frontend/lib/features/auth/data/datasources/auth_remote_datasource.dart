import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_cookies.dart';
import '../models/user_model.dart';

/// Auth remote data source - gọi AuthController của BE
abstract class AuthRemoteDataSource {
  Future<AuthSession> login({required String email, required String password});
  Future<void> register(Map<String, dynamic> body);
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resendOtp({required String email});
  Future<void> logout();
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final response = await _client.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = unwrapData<Map<String, dynamic>>(response);
    final tokens = TokenCookies.fromResponse(response, data);
    if (tokens.access.isEmpty) {
      throw Exception('Đăng nhập thành công nhưng không nhận được token từ BE.');
    }
    return AuthSession.fromJson({
      ...data,
      'accessToken': tokens.access,
      'refreshToken': tokens.refresh,
    });
  }

  @override
  Future<void> register(Map<String, dynamic> body) async {
    await _client.dio.post(ApiConstants.register, data: body);
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await _client.dio.post(ApiConstants.verifyOtp, data: {'email': email, 'otp': otp});
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await _client.dio.post(ApiConstants.resendOtp, data: {'email': email});
  }

  @override
  Future<void> logout() async {
    await _client.dio.post(ApiConstants.logout);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _client.dio.get(ApiConstants.me);
    return UserModel.fromJson(unwrapData<Map<String, dynamic>>(response));
  }
}
