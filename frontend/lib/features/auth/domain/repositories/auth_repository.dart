import '../entities/user.dart';

/// Auth repository interface - Domain layer
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> forgotPassword({required String email});
}
