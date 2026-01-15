import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String email;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    required this.email,
    this.password,
    this.profilePicture,
  });

  // Convert to JSON safely (omit nulls)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'email': email,
    };

    if (password != null) data['password'] = password;
    if (profilePicture != null) data['profilePicture'] = profilePicture;

    return data;
  }

  // Create model from JSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      email: json['email'] as String,
      password: json['password'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  // Convert to Entity
  AuthEntity toEntity() {
    return AuthEntity(
      email: email,
      password: password,
      profilePicture: profilePicture,
    );
  }

  // Create model from Entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      email: entity.email,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  // Convert a list of models to a list of entities
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
