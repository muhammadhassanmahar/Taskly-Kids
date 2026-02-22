import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Role argument from RoleScreen
    final roleArg = ModalRoute.of(context)?.settings.arguments;
    final role = roleArg is String ? roleArg : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 140),
                const SizedBox(height: 20),

                // ================= EMAIL =================
                TextField(
                  controller: email,
                  style: const TextStyle(color: Colors.white),
                  decoration: input("Email"),
                ),
                const SizedBox(height: 10),

                // ================= PASSWORD =================
                TextField(
                  controller: password,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: input("Password"),
                ),
                const SizedBox(height: 20),

                // ================= LOGIN BUTTON =================
                loading
                    ? const CircularProgressIndicator(color: Colors.yellow)
                    : ElevatedButton(
                        onPressed: () async {
                          // Field validation
                          if (email.text.isEmpty || password.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() => loading = true);

                          try {
                            // ✅ Firebase Auth login with named parameters
                            final ok = await FirebaseAuthService.login(
                              email: email.text.trim(),
                              password: password.text.trim(),
                            );

                            if (!mounted) return;

                            if (ok) {
                              // Navigation arguments
                              final navArgs = {
                                role == 'parent'
                                    ? 'parentEmail'
                                    : 'childEmail': email.text.trim(),
                              };

                              final targetRoute = role == 'parent'
                                  ? '/parent'
                                  : role == 'child'
                                      ? '/child'
                                      : '/role';

                              Navigator.pushReplacementNamed(
                                context,
                                targetRoute,
                                arguments: navArgs,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Login failed! Check credentials."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Login error: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => loading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Login"),
                      ),

                const SizedBox(height: 10),

                // ================= SIGNUP NAV =================
                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pushNamed(
                      context,
                      '/signup',
                      arguments: role,
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );
}
