import 'auth_bridge.dart'; // Import the bridge helper we made
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_page.dart';
import 'register_page.dart'; // ← make sure this import is added

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  // ----------------------------
  // 🆕 NEW: GUEST LOGIN LOGIC
  // ----------------------------
  Future<void> _continueAsGuest() async {
    try {
      setState(() => loading = true);
      // Sign in anonymously with Firebase directly
      // This bypasses Supabase/Bridge because guests don't need sync
      await FirebaseAuth.instance.signInAnonymously();
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Guest login failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  // ----------------------------
  // EMAIL + PASSWORD LOGIN LOGIC (Firebase Only)
  // ----------------------------
  Future<void> login() async {
    try {
      setState(() => loading = true);

      // Firebase login
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user == null) throw "Login failed";

      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => loading = false);
    }
  }

  // Supabase login, MFA, and bridge logic removed. Registration remains on Supabase.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fc),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------
              // INTRO TEXT
              // -------------------------
              Center(
                child: Text(
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Log in to continue your wellbeing journey.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // -------------------------------------
              // EMAIL + PASSWORD FIELDS
              // -------------------------------------
              ...[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => showPassword = !showPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ForgotPasswordPage()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.indigo.shade700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // --------------------------
                // UPDATED REGISTER LINK
                // --------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // GUEST LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : _continueAsGuest,
                    icon: const Icon(Icons.person_outline),
                    label: const Text("Continue as Guest"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      side: BorderSide(color: Colors.indigo.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
