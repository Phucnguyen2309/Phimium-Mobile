import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart' as domain;
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements domain.AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _remoteDataSource.login(request);

    // Save tokens & user locally
    await _localDataSource.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localDataSource.saveUser(response.user);

    return response.user.toEntity();
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final request = RegisterRequest(
      email: email,
      password: password,
      fullName: fullName,
    );
    final response = await _remoteDataSource.register(request);

    await _localDataSource.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localDataSource.saveUser(response.user);

    return response.user.toEntity();
  }

  @override
  Future<void> logout() async {
    final token = await _localDataSource.getAccessToken();
    if (token != null) {
      try {
        await _remoteDataSource.logout(token);
      } catch (_) {
        // Ignore remote logout errors
      }
    }
    await _localDataSource.clearAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    final cached = await _localDataSource.getCachedUser();
    if (cached != null) {
      return cached.toEntity();
    }

    final token = await _localDataSource.getAccessToken();
    if (token != null) {
      try {
        final userModel = await _remoteDataSource.getProfile(token);
        await _localDataSource.saveUser(userModel);
        return userModel.toEntity();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.isLoggedIn();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    // TODO: Implement forgot password API call
    throw UnimplementedError();
  }
}
