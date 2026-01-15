import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/api/api_client.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';
import 'package:jerseypasal/features/auth/data/datasources/auth_datasource.dart';
import 'package:jerseypasal/features/auth/data/models/auth_api_model.dart';

// Provider
final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register, // Use your correct endpoint
      data: user.toJson(),
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid server response');
    }

    final data = response.data as Map<String, dynamic>;

    if (data['success'] == true && data['data'] != null) {
      return AuthApiModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  @override
  Future<AuthApiModel> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid server response');
    }

    final data = response.data as Map<String, dynamic>;

    if (data['success'] == true && data['data'] != null) {
      final userData = data['data'] as Map<String, dynamic>;

      // Save user session immediately
      final userId = userData['_id'] as String; // <- make sure to extract '_id'
      await _userSessionService.saveUserSession(
        userId: userId,
        email: userData['email'] as String,
        token: data['token'] as String?, // save token if your API returns it
      );

      return AuthApiModel.fromJson(userData);
    }

    throw Exception(data['message'] ?? 'Login failed');
  }

  @override
  Future<AuthApiModel> getUserById(String authId) async {
    final response = await _apiClient.get(ApiEndpoints.userById(authId));

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid server response');
    }

    final data = response.data as Map<String, dynamic>;

    if (data['success'] == true && data['data'] != null) {
      return AuthApiModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to fetch user');
  }
}
