import '../../../../core/network/api_result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<ApiResult<User>> call({
    required String email,
    required String password,
  }) async {
    try {
      final user = await repository.login(email: email, password: password);
      return ApiSuccess(user);
    } catch (e) {
      return ApiError(e.toString());
    }
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<ApiResult<User>> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = await repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      return ApiSuccess(user);
    } catch (e) {
      return ApiError(e.toString());
    }
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<ApiResult<void>> call() async {
    try {
      await repository.logout();
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError(e.toString());
    }
  }
}

class CheckAuthUseCase {
  final AuthRepository repository;

  CheckAuthUseCase(this.repository);

  Future<ApiResult<User?>> call() async {
    try {
      final isLoggedIn = await repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await repository.getCurrentUser();
        return ApiSuccess(user);
      }
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError(e.toString());
    }
  }
}
