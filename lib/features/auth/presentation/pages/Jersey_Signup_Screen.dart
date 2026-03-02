import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/app/routes/app_routes.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';
import 'package:jerseypasal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';

class JerseySignupScreen extends ConsumerStatefulWidget {
  const JerseySignupScreen({super.key});

  @override
  ConsumerState<JerseySignupScreen> createState() => _JerseySignupScreenState();
}

class _JerseySignupScreenState extends ConsumerState<JerseySignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> agreeToTerms = ValueNotifier(false);

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    agreeToTerms.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // ── Decorative background blobs ──
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF533483).withOpacity(0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE94560).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 52),

                        // ── Logo / Brand ──
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF533483),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.sports_soccer,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Headline ──
                        const Text(
                          'Create your\naccount.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join Jerseyपसल today',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Email ──
                        _buildLabel('Email'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: emailController,
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Email cannot be empty';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ── Password ──
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: passwordController,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white38,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Password cannot be empty';
                            if (value.trim().length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ── Confirm Password ──
                        _buildLabel('Confirm Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: confirmPasswordController,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white38,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Confirm your password';
                            if (value != passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Terms checkbox ──
                        ValueListenableBuilder<bool>(
                          valueListenable: agreeToTerms,
                          builder: (context, value, _) {
                            return GestureDetector(
                              onTap: () =>
                                  agreeToTerms.value = !agreeToTerms.value,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: value
                                          ? const Color(0xFFE94560)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: value
                                            ? const Color(0xFFE94560)
                                            : Colors.white24,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: value
                                        ? const Icon(Icons.check,
                                            color: Colors.white,
                                            size: 14)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'I agree to the Terms & Conditions and Privacy Policy',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // ── Sign Up button ──
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    if (!agreeToTerms.value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'You must agree to Terms & Privacy Policy'),
                                          backgroundColor:
                                              const Color(0xFFE94560),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                      return;
                                    }
                                    ref
                                        .read(authViewModelProvider.notifier)
                                        .register(
                                          context: context,
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE94560),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFFE94560).withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Divider ──
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.white12, thickness: 1)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('or',
                                  style: TextStyle(
                                      color: Colors.white24, fontSize: 13)),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.white12, thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Login redirect ──
                        Center(
                          child: GestureDetector(
                            onTap: () => AppRoutes.pushReplacement(
                                context, const JerseyLoginScreen()),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Already have an account?  ',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'Sign in',
                                    style: TextStyle(
                                      color: Color(0xFFE94560),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE94560),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE94560), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE94560), width: 1.5),
        ),
        errorStyle:
            const TextStyle(color: Color(0xFFE94560), fontSize: 11),
      ),
    );
  }
}