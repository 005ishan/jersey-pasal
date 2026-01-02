import 'package:flutter/material.dart';

class SnackbarUtils {
  // ===================== Show Error =====================
  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
    );
  }

  // ===================== Show Success =====================
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  // ===================== Private Helper =====================
  static void _showSnackbar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
