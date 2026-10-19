import 'package:equatable/equatable.dart';

/// User entity - Domain layer
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final int coinBalance;
  final String? phone;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.coinBalance = 0,
    this.phone,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl, coinBalance];
}
