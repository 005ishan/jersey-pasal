import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String email;
  final String? password;
  final String? profilePicture;

  AuthApiModel({required this.email, this.password, this.profilePicture});

  //toJSON
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "profilePicture": profilePicture,
    };
  }

  //fromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      email: json['email'] as String,
      password: json['password'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }
  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      email: email,
      password: password,
      profilePicture: profilePicture,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      email: entity.email,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }
  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
