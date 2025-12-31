import 'package:hive/hive.dart';
import 'package:jerseypasal/core/constants/hive_table_constant.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject{

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
}