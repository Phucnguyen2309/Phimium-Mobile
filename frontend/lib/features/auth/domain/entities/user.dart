import 'package:equatable/equatable.dart';

/// User entity - Domain layer (khớp MeResponse / LoginResponse của BE)
class User extends Equatable {
  final String id;
  final String email; // BE gọi là username
  final String fullName;
  final String role; // USER, BUDDY, ADMIN
  final String? buddyId;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'USER',
    this.buddyId,
  });

  bool get isBuddy => buddyId != null && buddyId!.isNotEmpty;

  @override
  List<Object?> get props => [id, email, fullName, role, buddyId];
}
