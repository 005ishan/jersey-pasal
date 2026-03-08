import 'package:flutter/material.dart';
import 'package:jerseypasal/app/routes/app_routes.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';

class JerseyOnboardingScreen extends StatefulWidget {
  const JerseyOnboardingScreen({super.key});

  @override
  State<JerseyOnboardingScreen> createState() => _JerseyOnboardingScreenState();
}

class _JerseyOnboardingScreenState extends State<JerseyOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      headline: 'Welcome to\nJERSEYपसल',
      subtitle: 'Your one-stop destination for\npremium and authentic jerseys.',
      images: [
        'assets/images/jersey1.jpg',
        'assets/images/jersey2.jpg',
        'assets/images/jersey3.jpg',
      ],
    ),
    _OnboardingData(
      headline: 'Choose Your\nTeam',
      subtitle: 'Find jerseys from all your favorite\nclubs and national teams.',
      images: [
        'assets/images/jersey5.jpg',
        'assets/images/jersey4.jpg',
        'assets/images/jersey6.jpg',
      ],
    ),
    _OnboardingData(
      headline: 'Premium\nQuality',
      subtitle: 'We deliver premium, durable, and\ncustomer-approved jerseys.',
      images: [
        'assets/images/jersey7.jpg',
        'assets/images/jersey8.jpg',
        'assets/images/jersey9.jpg',
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      AppRoutes.pushReplacement(context, const JerseyLoginScreen());
    }
  }

  void _skip() {
    AppRoutes.pushReplacement(context, const JerseyLoginScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // ── Background blobs (static, no flicker) ──
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFE94560).withOpacity(0.22),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF533483).withOpacity(0.32),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand
                      Row(children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE94560),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.sports_soccer,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'JERSEYपसल',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ]),

                      // Skip button (hidden on last page)
                      AnimatedOpacity(
                        opacity: isLast ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: GestureDetector(
                          onTap: _skip,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── PageView (images only slide) ──
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ImageMosaic(images: _pages[index].images),
                      );
                    },
                  ),
                ),

                // ── Bottom content (text + dots + button — no rebuild flicker) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step dots
                      Row(
                        children: List.generate(_pages.length, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 28 : 8,
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

                      const SizedBox(height: 20),

                      // Headline — animates on page change
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Align(
                          key: ValueKey(_currentPage),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _pages[_currentPage].headline,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Subtitle — animates on page change
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: Align(
                          key: ValueKey('sub_$_currentPage'),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _pages[_currentPage].subtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Next / Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Row(
                              key: ValueKey(isLast),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLast ? 'Get Started' : 'Next',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image mosaic widget ──────────────────────────────────────────────────────
class _ImageMosaic extends StatelessWidget {
  final List<String> images;
  const _ImageMosaic({required this.images});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _imgCard(images[0])),
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
    );
  }

  Widget _imgCard(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
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

// ─── Data model ──────────────────────────────────────────────────────────────
class _OnboardingData {
  final String headline;
  final String subtitle;
  final List<String> images;
  const _OnboardingData({
    required this.headline,
    required this.subtitle,
    required this.images,
  });
}