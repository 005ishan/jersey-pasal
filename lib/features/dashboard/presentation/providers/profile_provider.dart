import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jerseypasal/core/api/api_client.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';
import 'package:jerseypasal/features/dashboard/data/repositories/profile_repository.dart';

// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final userSessionService = ref.watch(userSessionServiceProvider);
  
  return ProfileRepository(
    apiClient: apiClient,
    userSessionService: userSessionService,
  );
});

// Upload profile picture state notifier
final uploadProfilePictureProvider = StateNotifierProvider<
    UploadProfilePictureNotifier,
    AsyncValue<String>>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return UploadProfilePictureNotifier(profileRepository);
});

class UploadProfilePictureNotifier extends StateNotifier<AsyncValue<String>> {
  final ProfileRepository _profileRepository;

  UploadProfilePictureNotifier(this._profileRepository)
      : super(const AsyncValue.data(''));

  Future<void> uploadProfilePicture(
    dynamic imageFile, {
    void Function(int, int)? onProgress,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _profileRepository.uploadProfilePicture(
        imageFile: imageFile,
        onProgress: onProgress,
      ),
    );
  }

  void reset() {
    state = const AsyncValue.data('');
  }
}

// Fetch user profile provider
final fetchUserProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return profileRepository.getUserProfile();
});
