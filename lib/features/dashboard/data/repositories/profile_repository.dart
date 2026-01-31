import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jerseypasal/core/api/api_client.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  ProfileRepository({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  /// ─────────────────────────────────────────────
  /// UPLOAD PROFILE PICTURE
  /// ─────────────────────────────────────────────
  Future<String> uploadProfilePicture({
    required XFile imageFile,
    void Function(int, int)? onProgress,
  }) async {
    final userId = _userSessionService.getUserId();
    if (userId == null) {
      throw Exception('User ID not found. Please login again.');
    }

    // Token check (async — SecureStorage)
    final token = await _userSessionService.getAuthToken();
    print('🔐 Auth Token exists: ${token != null}');

    final options = Options(
      headers: {
        'Authorization': 'Bearer $token', // attach token
      },
      validateStatus: (status) => true,
    );

    const String uploadEndpoint = '/users/upload';

    try {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      print('═' * 60);
      print('Uploading profile picture');
      print('UserId: $userId');
      print('File: ${imageFile.name}');
      print('Endpoint: $uploadEndpoint');
      print('═' * 60);

      final response = await _apiClient.uploadFile(
        uploadEndpoint,
        formData: formData,
        options: options,
        onSendProgress: onProgress,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Extract image URL
        final data = response.data;
        String? photoUrl;

        if (data is Map) {
          photoUrl =
              data['data']?['profilePicture'] ??
              data['profilePicture'] ??
              data['data']?['photoUrl'] ??
              data['photoUrl'] ??
              data['data']?['url'] ??
              data['url'];
        }

        // Update local session
        await _userSessionService.saveUserSession(
          userId: userId,
          email: _userSessionService.getUserEmail() ?? '',
          profilePicture: photoUrl,
        );

        return photoUrl ?? imageFile.path;
      } else {
        final message = response.data is Map ? response.data['message'] : null;
        throw Exception(message ?? 'Upload failed');
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? e.response?.data['message']
          : e.message;
      throw Exception(msg ?? 'Upload failed');
    }
  }

  /// ─────────────────────────────────────────────
  /// GET USER PROFILE
  /// ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getUserProfile() async {
    final userId = _userSessionService.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final response = await _apiClient.get(ApiEndpoints.userById(userId));

    if (response.statusCode == 200) {
      return response.data['data'] ?? response.data;
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// ─────────────────────────────────────────────
  /// DELETE PROFILE PICTURE
  /// ─────────────────────────────────────────────
  Future<void> deleteProfilePicture() async {
    final userId = _userSessionService.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    await _apiClient.delete(ApiEndpoints.userProfilePicture(userId));

    await _userSessionService.saveUserSession(
      userId: userId,
      email: _userSessionService.getUserEmail() ?? '',
      profilePicture: null,
    );
  }

  /// ─────────────────────────────────────────────
  /// LOGOUT
  /// ─────────────────────────────────────────────
  Future<void> logout() async {
    await _userSessionService.clearSession();
  }
}
