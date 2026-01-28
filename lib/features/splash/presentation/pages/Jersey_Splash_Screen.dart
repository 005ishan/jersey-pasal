import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/app/routes/app_routes.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';
import 'package:jerseypasal/features/dashboard/presentation/widgets/DashboardLayout.dart';
import '../../../onboarding/presentation/pages/Jersey_Onboarding1_Screen.dart';

class JerseySplashScreen extends ConsumerStatefulWidget {
  const JerseySplashScreen({super.key});

  @override
  ConsumerState<JerseySplashScreen> createState() => _JerseySplashScreenState();
}

class _JerseySplashScreenState extends ConsumerState<JerseySplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const DashboardLayout());
    } else {
      AppRoutes.pushReplacement(context, const JerseyOnboarding1Screen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 25),
            Text(
              'JERSEYपसल',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Authentic Football Jerseys',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
