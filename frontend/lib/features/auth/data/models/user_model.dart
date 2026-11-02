import '../../domain/entities/user.dart';

/// UserModel - parse từ MeResponse của BE:
/// { userId, username, fullName, role, buddyId }
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? buddyId;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'USER',
    this.buddyId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['userId'] ?? json['id'] ?? '').toString(),
        email: (json['username'] ?? json['email'] ?? '').toString(),
        fullName: (json['fullName'] ?? '').toString(),
        role: (json['role'] ?? 'USER').toString(),
        buddyId: json['buddyId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'userId': id,
        'username': email,
        'fullName': fullName,
        'role': role,
        'buddyId': buddyId,
      };

  User toEntity() => User(
        id: id,
        email: email,
        fullName: fullName,
        role: role,
        buddyId: buddyId,
      );
}

/// LoginResponse của BE:
/// { username, fullName, accessToken, refreshToken, buddyId, role }
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String email;
  final String fullName;
  final String role;
  final String? buddyId;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.fullName,
    required this.role,
    this.buddyId,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: (json['accessToken'] ?? '').toString(),
        refreshToken: (json['refreshToken'] ?? '').toString(),
        email: (json['username'] ?? '').toString(),
        fullName: (json['fullName'] ?? '').toString(),
        role: (json['role'] ?? 'USER').toString(),
        buddyId: json['buddyId']?.toString(),
      );
}
