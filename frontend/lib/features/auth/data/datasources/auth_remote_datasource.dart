import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Auth remote data source interface
abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout(String token);
  Future<UserModel> getProfile(String token);
}

/// Auth remote data source implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _client.dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<void> logout(String token) async {
    await _client.dio.post(
      ApiConstants.logout,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  @override
  Future<UserModel> getProfile(String token) async {
    final response = await _client.dio.get(
      ApiConstants.profile,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return UserModel.fromJson(response.data);
  }
}
