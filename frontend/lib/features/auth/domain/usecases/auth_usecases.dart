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
      return ApiSuccess(await repository.login(email: email, password: password));
    } catch (e) {
      return ApiError(readableError(e));
    }
  }
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<ApiResult<void>> call({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthday,
    required String phone,
  }) async {
    try {
      await repository.register(
        email: email,
        password: password,
        fullName: fullName,
        birthday: birthday,
        phone: phone,
      );
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError(readableError(e));
    }
  }
}

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<ApiResult<void>> call({required String email, required String otp}) async {
    try {
      await repository.verifyOtp(email: email, otp: otp);
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError(readableError(e));
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
      return ApiError(readableError(e));
    }
  }
}

class CheckAuthUseCase {
  final AuthRepository repository;
  CheckAuthUseCase(this.repository);

  Future<ApiResult<User?>> call() async {
    try {
      if (await repository.isLoggedIn()) {
        return ApiSuccess(await repository.getCurrentUser());
      }
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError(readableError(e));
    }
  }
}
