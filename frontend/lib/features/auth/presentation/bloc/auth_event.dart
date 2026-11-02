part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final DateTime birthday;
  final String phone;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.birthday,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, fullName, birthday, phone];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyOtpRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class AuthLogoutRequested extends AuthEvent {}
