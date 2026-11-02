import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

/// Auth local data source - lưu token & thông tin user
abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getAccessToken();
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
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await _storage.write(key: StorageKeys.isLoggedIn, value: 'true');
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: StorageKeys.accessToken);

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: StorageKeys.userId, value: user.id);
    await _storage.write(key: StorageKeys.userEmail, value: user.email);
    await _storage.write(key: StorageKeys.userName, value: user.fullName);
    await _storage.write(key: StorageKeys.userRole, value: user.role);
    if (user.buddyId != null) {
      await _storage.write(key: StorageKeys.buddyId, value: user.buddyId);
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
      role: await _storage.read(key: StorageKeys.userRole) ?? 'USER',
      buddyId: await _storage.read(key: StorageKeys.buddyId),
    );
  }

  @override
  Future<bool> isLoggedIn() async =>
      (await _storage.read(key: StorageKeys.isLoggedIn)) == 'true';

  @override
  Future<void> clearAll() => _storage.deleteAll();
}
