import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String email;
  final String? password;
  final String? fullName;
  final String? profilePicture;

  const AuthEntity({
    required this.email,
    this.password,
    this.profilePicture,
    this.authId,
    this.fullName,
  });

  @override
  List<Object?> get props => [
    authId,
    email,
    password,
    fullName,
    profilePicture,
  ];
}
