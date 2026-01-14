import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/app/routes/app_routes.dart';
import 'package:jerseypasal/core/utils/snackbar_utils.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';
import 'package:jerseypasal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';

class JerseySignupScreen extends ConsumerStatefulWidget {
  const JerseySignupScreen({super.key});

  @override
  ConsumerState<JerseySignupScreen> createState() => _JerseySignupScreenState();
}

class _JerseySignupScreenState extends ConsumerState<JerseySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> agreeToTerms = ValueNotifier(false);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    agreeToTerms.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Create an account in',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Jerseyपसल',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
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
                  const SizedBox(height: 15),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
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
                  const SizedBox(height: 15),

                  // Confirm Password
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Terms & Conditions
                  ValueListenableBuilder<bool>(
                    valueListenable: agreeToTerms,
                    builder: (context, value, _) {
                      return CheckboxListTile(
                        value: value,
                        onChanged: (val) => agreeToTerms.value = val ?? false,
                        title: const Text(
                          "I agree to the Terms & Conditions and Privacy Policy",
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authState.status == AuthStatus.loading
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              if (!agreeToTerms.value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "You must agree to Terms & Privacy Policy",
                                    ),
                                  ),
                                );
                                return;
                              }

                              ref
                                  .read(authViewModelProvider.notifier)
                                  .register(
                                    context: context,
                                    email: emailController.text.trim(),
                                    username: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                            },
                      child: authState.status == AuthStatus.loading
                          ? const CircularProgressIndicator()
                          : const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Login redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          AppRoutes.pushReplacement(
                            context,
                            const JerseyLoginScreen(),
                          );
                        },
                        child: Text(
                          "Login",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
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
