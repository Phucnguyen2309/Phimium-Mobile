import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

/// Auth local data source - lưu token & thông tin user
/// - Android / iOS: dùng nguyên FlutterSecureStorage
/// - Web (kIsWeb): dùng SharedPreferences để tránh lỗi WebCrypto trên các port ngẫu nhiên
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

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _storage.read(key: key);
  }

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _write(StorageKeys.accessToken, accessToken);
    await _write(StorageKeys.refreshToken, refreshToken);
    await _write(StorageKeys.isLoggedIn, 'true');
  }

  @override
  Future<String?> getAccessToken() => _read(StorageKeys.accessToken);

  @override
  Future<void> saveUser(UserModel user) async {
    await _write(StorageKeys.userId, user.id);
    await _write(StorageKeys.userEmail, user.email);
    await _write(StorageKeys.userName, user.fullName);
    await _write(StorageKeys.userRole, user.role);
    if (user.buddyId != null) {
      await _write(StorageKeys.buddyId, user.buddyId!);
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final id = await _read(StorageKeys.userId);
    final email = await _read(StorageKeys.userEmail);
    final name = await _read(StorageKeys.userName);
    if (id == null || email == null || name == null) return null;

    return UserModel(
      id: id,
      email: email,
      fullName: name,
      role: await _read(StorageKeys.userRole) ?? 'USER',
      buddyId: await _read(StorageKeys.buddyId),
    );
  }

  @override
  Future<bool> isLoggedIn() async =>
      (await _read(StorageKeys.isLoggedIn)) == 'true';

  @override
  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.accessToken);
      await prefs.remove(StorageKeys.refreshToken);
      await prefs.remove(StorageKeys.isLoggedIn);
      await prefs.remove(StorageKeys.userId);
      await prefs.remove(StorageKeys.userEmail);
      await prefs.remove(StorageKeys.userName);
      await prefs.remove(StorageKeys.userRole);
      await prefs.remove(StorageKeys.buddyId);
      return;
    }
    await _storage.deleteAll();
  }
}
