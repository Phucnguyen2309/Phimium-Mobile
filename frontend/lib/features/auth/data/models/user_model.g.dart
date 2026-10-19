// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator - Placeholder
// Run `flutter pub run build_runner build` to generate actual code
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      coinBalance: json['coin_balance'] as int? ?? 0,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'coin_balance': instance.coinBalance,
      'phone': instance.phone,
      'created_at': instance.createdAt,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'user': instance.user.toJson(),
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['full_name'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'full_name': instance.fullName,
    };
