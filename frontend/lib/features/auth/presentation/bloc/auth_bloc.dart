import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._verifyOtpUseCase,
    this._logoutUseCase,
    this._checkAuthUseCase,
  ) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckAuth);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthLogoutRequested>(_onLogout);
  }

  /// User hiện tại (null nếu chưa đăng nhập)
  User? get currentUser {
    final s = state;
    return s is AuthAuthenticated ? s.user : null;
  }

  Future<void> _onCheckAuth(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _checkAuthUseCase.call();
    switch (result) {
      case ApiSuccess(data: final user):
        emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
      case ApiError():
        emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginUseCase.call(email: event.email, password: event.password);
    switch (result) {
      case ApiSuccess(data: final user):
        emit(AuthAuthenticated(user));
      case ApiError(message: final message):
        emit(AuthError(message));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerUseCase.call(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      birthday: event.birthday,
      phone: event.phone,
    );
    switch (result) {
      case ApiSuccess():
        emit(AuthRegisterSuccess(event.email));
      case ApiError(message: final message):
        emit(AuthError(message));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _verifyOtpUseCase.call(email: event.email, otp: event.otp);
    switch (result) {
      case ApiSuccess():
        emit(AuthOtpVerified());
      case ApiError(message: final message):
        emit(AuthError(message));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _logoutUseCase.call();
    emit(AuthUnauthenticated());
  }
}
