import 'package:jerseypasal/features/auth/data/datasources/auth_datasource.dart';
import 'package:jerseypasal/features/auth/data/models/auth_hive_model.dart';

class AuthRemoteDatasource implements IAuthRemoteDataSource{

  final ApiClient _apiClient;
  final 


  @override
  Future<AuthHiveModel> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel> login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) {
    // TODO: implement register
    throw UnimplementedError();
  }

}