import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';
import 'package:jerseypasal/features/dashboard/presentation/providers/profile_provider.dart';
import 'package:jerseypasal/features/dashboard/presentation/widgets/account_settings_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class JerseyProfileScreen extends ConsumerStatefulWidget {
  const JerseyProfileScreen({super.key});

  @override
  ConsumerState<JerseyProfileScreen> createState() =>
      _JerseyProfileScreenState();
}

class _JerseyProfileScreenState extends ConsumerState<JerseyProfileScreen> {
  String _userName = 'Customer';
  String? _profileUrl;

  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
  }

  void _openAccountSettings() {
    showDialog(
      context: context,
      builder: (context) => AccountSettingsDialog(
        currentName: _userName,
        onNameChanged: _updateUserName,
      ),
    );
  }

  final List<XFile> _selectedMedia = []; //images . video
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfilePicture(); // ✅ Load saved profile pic
  }

  Future<void> _loadProfilePicture() async {
    final userSession = ref.read(userSessionServiceProvider);
    setState(() {
      _profileUrl = userSession.getUserProfileImage();
    });
  }

  Future<bool> _requestMediaPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result.isGranted;
    }
  }

  //code for gallery
  Future<void> _pickFromGallery() async {
    final hasPermission = await _requestMediaPermission(Permission.photos);
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });
      // Upload the photo immediately
      await _uploadProfilePicture(photo);
    }
  }

  //code for camera
  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestMediaPermission(Permission.camera);
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });
      // Upload the photo immediately
      await _uploadProfilePicture(photo);
    }
  }

  // Upload profile picture to backend
  Future<void> _uploadProfilePicture(XFile imageFile) async {
    // Show loading indicator
    _showUploadDialog();

    try {
      final profileRepository = ref.read(profileRepositoryProvider);

      // 1️⃣ Upload to backend
      final uploadedImageUrl = await profileRepository.uploadProfilePicture(
        imageFile: imageFile,
        onProgress: (sent, total) {},
      );

      // 2️⃣ Save the returned URL to local session
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getUserId();
      if (userId != null) {
        await userSession.saveUserSession(
          userId: userId,
          email: userSession.getUserEmail() ?? '',
          profilePicture: uploadedImageUrl, // <-- save full URL here
        );
      }

      // 3️⃣ Close loading dialog
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog('Profile picture updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        _showErrorDialog(
          errorMsg.isNotEmpty ? errorMsg : 'Failed to upload image',
        );
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This app needs permission to access your media files.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text("Uploading profile picture..."),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Photo Source"),
        content: const Text("Select where you want to pick the photo from"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
            child: const Text("Gallery"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickFromCamera();
            },
            child: const Text("Camera"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileUrl = ref
        .read(userSessionServiceProvider)
        .getUserProfileImage();

    return Scaffold(
      appBar: JerseyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Blue Gradient Header with Profile
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1877F2), Colors.blue.shade300],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  // Circular Profile Photo with Border
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipOval(
                            child: (profileUrl != null && profileUrl.isNotEmpty)
                                ? Image.network(
                                    _profileUrl!,
                                    fit: BoxFit.cover,
                                    width: 160,
                                    height: 160,
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 80,
                                    color: const Color(0xFF1877F2),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1877F2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Name
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // User Email
                  const Text(
                    'customer@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE3F2FD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // White Content Area with Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Order History Button
                  _buildModernButton(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Order History',
                    subtitle: 'View your past purchases',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  // Account Settings Button
                  _buildModernButton(
                    icon: Icons.settings_outlined,
                    title: 'Account Settings',
                    subtitle: 'Manage your account',
                    onTap: _openAccountSettings,
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1877F2).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: const Color(0xFF1877F2), size: 28),
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout,
                      color: Color(0xFFEF4444),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Logout?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                const Text(
                  'Are you sure you want to logout from your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      // 1️⃣ Clear auth data (token, user data)
                      final profileRepository = ref.read(
                        profileRepositoryProvider,
                      );
                      await profileRepository
                          .logout(); // or clear token manually

                      // 2️⃣ Clear local session including profile picture
                      final userSession = ref.read(userSessionServiceProvider);
                      await userSession.clearSession();
                      setState(() {
                        _profileUrl = null; // Reset local profile picture
                      });

                      // 3️⃣ Close dialog
                      Navigator.pop(context);

                      // 4️⃣ Navigate to Login & clear stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JerseyLoginScreen(),
                        ),
                        (route) => false,
                      );
                    },

                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
