import 'package:flutter/material.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';

class JerseySignupScreen extends StatelessWidget {
  JerseySignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> agreeToTerms = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SafeArea(
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

                  /// Email
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

                  /// Password
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

                  /// Confirm Password
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

                  ValueListenableBuilder<bool>(
                    valueListenable: agreeToTerms,
                    builder: (context, value, _) {
                      return CheckboxListTile(
                        value: value,
                        onChanged: (val) {
                          agreeToTerms.value = val ?? false;
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: const VisualDensity(
                          horizontal: -4, 
                          vertical: -4,
                        ),
                        title: Transform.translate(
                          offset: const Offset(-8, 0), 
                          child: Wrap(
                            children: [
                              Text(
                                "I agree to the ",
                                style: theme.textTheme.bodySmall,
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Terms & Conditions",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(" and ", style: theme.textTheme.bodySmall),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Privacy Policy",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  /// Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        if (!agreeToTerms.value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "You must agree to the Terms & Conditions and Privacy Policy",
                              ),
                            ),
                          );
                          return;
                        }

                        // ✅ Signup logic here
                      },
                      child: const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// Login redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JerseyLoginScreen(),
                            ),
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
