import '../entities/user.dart';

/// Auth repository interface - Domain layer
abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  /// BE gửi OTP về email sau khi đăng ký, chưa trả token.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthday,
    required String phone,
  });

  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resendOtp({required String email});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
}
