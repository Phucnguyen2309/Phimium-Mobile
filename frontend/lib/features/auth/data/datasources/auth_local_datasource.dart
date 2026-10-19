import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

/// Auth local data source - manages token & user cache
abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<bool> isLoggedIn();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await _storage.write(key: StorageKeys.isLoggedIn, value: 'true');
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: StorageKeys.userId, value: user.id);
    await _storage.write(key: StorageKeys.userEmail, value: user.email);
    await _storage.write(key: StorageKeys.userName, value: user.fullName);
    if (user.avatarUrl != null) {
      await _storage.write(key: StorageKeys.userAvatar, value: user.avatarUrl);
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final id = await _storage.read(key: StorageKeys.userId);
    final email = await _storage.read(key: StorageKeys.userEmail);
    final name = await _storage.read(key: StorageKeys.userName);

    if (id == null || email == null || name == null) return null;

    return UserModel(
      id: id,
      email: email,
      fullName: name,
      avatarUrl: await _storage.read(key: StorageKeys.userAvatar),
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: StorageKeys.isLoggedIn);
    return value == 'true';
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
