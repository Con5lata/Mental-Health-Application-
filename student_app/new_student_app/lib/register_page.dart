import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'totp_enroll_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false; // 👈 for password visibility toggle

  // ----------------------------
  // GOOGLE SIGN-IN LOGIC (Supabase)
  // ----------------------------
  Future<void> signInWithGoogle() async {
    try {
      setState(() => loading = true);
      // This will redirect the user to the Google sign-in page and back
            await supabase.Supabase.instance.client.auth.signInWithOAuth(supabase.OAuthProvider.google);
      // Navigation after OAuth is typically handled by a deep link or callback
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred during Google Sign-In: $e")));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ----------------------------
  // EMAIL + PASSWORD LOGIC (Supabase)
  // ----------------------------
  Future<void> registerWithEmail() async {
    try {
      setState(() => loading = true);
      final response = await supabase.Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'name': _nameController.text.trim(),
        },
      );
      if (response.user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TotpEnrollPage()),
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "A verification email has been sent. Please confirm it to continue.",
            ),
          ));
        }
      } else {
        throw Exception("Registration failed. Please try again.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: \\${e.toString()}")));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fc),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 👈 vertically centered
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------
              // INTRO TEXT
              // ------------------------
              Text(
                "Welcome to MindCare",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Your wellbeing matters. Create an account to access tools that support your mental health journey.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ------------------------
              // FULL NAME
              // ------------------------
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ------------------------
              // EMAIL
              // ------------------------
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

              // ------------------------
              // PASSWORD
              // ------------------------
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

              const SizedBox(height: 30),

              // ------------------------
              // EMAIL + PASSWORD BUTTON
              // ------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : registerWithEmail,
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
                          "Create Account",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------
              // OR DIVIDER
              // ------------------------
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.black26)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider(color: Colors.black26)),
                ],
              ),

              const SizedBox(height: 20),

              // ------------------------
              // GOOGLE SIGN-IN BUTTON
              // ------------------------
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: loading ? null : signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.indigo.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
                        height: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Sign up with Google",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------
              // LOGIN LINK
              // ------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  InkWell(
                    onTap: () => Navigator.pop(context), // Go back to the previous screen (login)
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
