import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/app/routes/app_routes.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';
import '../../../onboarding/presentation/pages/Jersey_Onboarding1_Screen.dart';
import '../../../dashboard/presentation/widgets/DashboardLayout.dart';

class JerseySplashScreen extends ConsumerStatefulWidget {
  const JerseySplashScreen({super.key});

  @override
  ConsumerState<JerseySplashScreen> createState() => _JerseySplashScreenState();
}

class _JerseySplashScreenState extends ConsumerState<JerseySplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToNext());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3200));
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // Top-right blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFE94560).withOpacity(0.3),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Bottom-left blob
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF533483).withOpacity(0.4),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated icon container
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (_, __) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE94560)
                                  .withOpacity(0.5 * _glowAnim.value),
                              blurRadius: 40 * _glowAnim.value,
                              spreadRadius: 4 * _glowAnim.value,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_soccer,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Brand name
                    const Text(
                      'JERSEYपसल',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Authentic Football Jerseys',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 56),

                    // Loading dots
                    FadeTransition(
                      opacity: _glowAnim,
                      child: const _PulsingDots(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final delay = i * 0.25;
        return AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = (_c.value - delay).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  Colors.white24,
                  const Color(0xFFE94560),
                  t,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}