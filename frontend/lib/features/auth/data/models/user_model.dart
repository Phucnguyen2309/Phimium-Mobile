import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'coin_balance', defaultValue: 0)
  final int coinBalance;
  final String? phone;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.coinBalance = 0,
    this.phone,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to domain entity
  User toEntity() => User(
        id: id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        coinBalance: coinBalance,
        phone: phone,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  /// Create from domain entity
  factory UserModel.fromEntity(User user) => UserModel(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        avatarUrl: user.avatarUrl,
        coinBalance: user.coinBalance,
        phone: user.phone,
        createdAt: user.createdAt?.toIso8601String(),
      );
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  @JsonKey(name: 'full_name')
  final String fullName;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
