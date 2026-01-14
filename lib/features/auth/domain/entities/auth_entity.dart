import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String email;
  final String? username;
  final String? password;
  final String? fullName;
  final String? profilePicture;

  const AuthEntity({
    required this.email,
    this.password,
    this.profilePicture,
    this.authId,
    this.username,
    this.fullName,
  });

  @override
  List<Object?> get props => [
    authId,
    email,
    username,
    password,
    fullName,
    profilePicture,
  ];
}
