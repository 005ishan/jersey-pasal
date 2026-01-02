import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/utils/snackbar_utils.dart';
import 'package:jerseypasal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';
import 'package:jerseypasal/core/widgets/JerseyBottonNavigation.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Signup_Screen.dart';

class JerseyLoginScreen extends ConsumerStatefulWidget {
  const JerseyLoginScreen({super.key});

  @override
  ConsumerState<JerseyLoginScreen> createState() => _JerseyLoginScreenState();
}

class _JerseyLoginScreenState extends ConsumerState<JerseyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _hasInitializedListener = false; // <- guard flag snackbar 2 choti aayo so

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authState = ref.watch(authViewModelProvider);

    if (!_hasInitializedListener) {
      _hasInitializedListener = true;
      ref.listen<AuthState>(authViewModelProvider, (previous, next) {
        if (previous?.status != next.status) {
          if (next.status == AuthStatus.error && next.errorMessage != null) {
            SnackbarUtils.showError(context, next.errorMessage!);
          } else if (next.status == AuthStatus.authenticated &&
              next.authEntity != null) {
            SnackbarUtils.showSuccess(context, "Login successful!");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const JerseyBottomNavigation()),
            );
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome to Jerseyपसल",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email cannot be empty';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password cannot be empty';
                      }
                      if (value.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authState.status == AuthStatus.loading
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;

                              ref
                                  .read(authViewModelProvider.notifier)
                                  .login(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                    context: context,
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: authState.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Signup redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JerseySignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
