import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<User> login({required String email, required String password}) async {
    final session = await _remote.login(email: email, password: password);
    await _local.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );

    // Lấy userId đầy đủ từ /api/auth/me; nếu lỗi thì dùng dữ liệu login
    UserModel user;
    try {
      user = await _remote.getMe();
    } catch (_) {
      user = UserModel(
        id: session.email,
        email: session.email,
        fullName: session.fullName,
        role: session.role,
        buddyId: session.buddyId,
      );
    }
    await _local.saveUser(user);
    return user.toEntity();
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthday,
    required String phone,
  }) {
    final y = birthday.year.toString().padLeft(4, '0');
    final m = birthday.month.toString().padLeft(2, '0');
    final d = birthday.day.toString().padLeft(2, '0');
    return _remote.register({
      'email': email,
      'password': password,
      'fullName': fullName,
      'birthday': '$y-$m-$d',
      'phone': phone,
    });
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) =>
      _remote.verifyOtp(email: email, otp: otp);

  @override
  Future<void> resendOtp({required String email}) => _remote.resendOtp(email: email);

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Bỏ qua lỗi logout phía server
    }
    await _local.clearAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    final cached = await _local.getCachedUser();
    if (cached != null) return cached.toEntity();

    if (await _local.getAccessToken() != null) {
      try {
        final user = await _remote.getMe();
        await _local.saveUser(user);
        return user.toEntity();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() => _local.isLoggedIn();
}
