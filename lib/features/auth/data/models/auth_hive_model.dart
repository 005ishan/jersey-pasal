import 'package:hive/hive.dart';
import 'package:jerseypasal/core/constants/hive_table_constant.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String username;
  @HiveField(4)
  final String? password;
  @HiveField(5)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.profilePicture,
  }) : authId = authId ?? Uuid().v4();

  //from Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  //to Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      email: email,
      username: username,
      fullName: fullName,
      password: password,
      profilePicture: profilePicture,
    );
  }

  // copyWith
  AuthHiveModel copyWith({
    String? authId,
    String? fullName,
    String? email,
    String? username,
    String? password,
    String? profilePicture,
  }) {
    return AuthHiveModel(
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
