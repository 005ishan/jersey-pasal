import 'package:flutter/material.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';
import 'package:jerseypasal/app/routes/app_routes.dart';

class JerseyOnboarding3Screen extends StatefulWidget {
  const JerseyOnboarding3Screen({super.key});

  @override
  State<JerseyOnboarding3Screen> createState() => _JerseyOnboarding3ScreenState();
}

class _JerseyOnboarding3ScreenState extends State<JerseyOnboarding3Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      fadeAnim: _fadeAnim,
      slideAnim: _slideAnim,
      step: 3,
      images: const [
        'assets/images/jersey7.jpg',
        'assets/images/jersey8.jpg',
        'assets/images/jersey9.jpg',
      ],
      headline: 'Premium\nQuality',
      subtitle: 'We deliver premium, durable, and\ncustomer-approved jerseys.',
      buttonLabel: 'Get Started',
      onNext: () => AppRoutes.pushReplacement(context, const JerseyLoginScreen()),
    );
  }
}

// ─── Shared onboarding shell — included in each onboarding file ──────────────
class _OnboardingShell extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final int step;
  final List<String> images;
  final String headline;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onNext;

  const _OnboardingShell({
    required this.fadeAnim,
    required this.slideAnim,
    required this.step,
    required this.images,
    required this.headline,
    required this.subtitle,
    required this.buttonLabel,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // Blobs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFE94560).withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF533483).withOpacity(0.35),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(
                position: slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Brand bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE94560),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.sports_soccer,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'JERSEYपसल',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ]),
                          // Step dots
                          Row(
                            children: List.generate(3, (i) {
                              final active = i + 1 == step;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 22 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFFE94560)
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Image mosaic
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _imgCard(images[0]),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(child: _imgCard(images[1])),
                                  const SizedBox(height: 10),
                                  Expanded(child: _imgCard(images[2])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Text content
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          headline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Button row
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE94560),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      buttonLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgCard(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          path,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}