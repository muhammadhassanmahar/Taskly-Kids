import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
    // Role argument from previous screen
    final role = ModalRoute.of(context)?.settings.arguments as String?;

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

                // ================= SIGNUP BUTTON =================
                loading
                    ? const CircularProgressIndicator(color: Colors.yellow)
                    : ElevatedButton(
                        onPressed: () async {
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
                            // ✅ Signup using FirebaseAuthService with named parameters
                            final ok = await FirebaseAuthService.signup(
                              email: email.text.trim(),
                              password: password.text.trim(),
                            );

                            if (!mounted) return;

                            if (ok) {
                              // Navigate to Role selection screen
                              Navigator.pushReplacementNamed(
                                context,
                                '/role',
                                arguments: role,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Signup failed! Try a different email."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $e"),
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
                        child: const Text("Create Account"),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
}
