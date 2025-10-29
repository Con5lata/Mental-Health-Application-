import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();

        // Hash the password using SHA256
        final passwordBytes = utf8.encode(_passwordController.text.trim());
        final hashedPassword = sha256.convert(passwordBytes).toString();

        // Save user details to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'name': _nameController.text.trim(),
          'email': user.email,
          'phone': _phoneController.text.trim(),
          'role': 'student',
          'password_hash': hashedPassword,
          'created_at': FieldValue.serverTimestamp(),
        });

        // Show success message and navigate back to the login screen
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please verify your email before logging in.'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'weak-password' => 'The password provided is too weak.',
        'email-already-in-use' => 'An account already exists for that email.',
        'invalid-email' => 'The email address is not valid.',
        _ => 'An error occurred. Please try again.',
      };
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('Create Account', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 28, color: theme.colorScheme.onSurface)),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email', labelStyle: GoogleFonts.poppins(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                      validator: (value) {
                        if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: GoogleFonts.poppins(),
                        hintText: 'e.g., 0712345678',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: Text('Register', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: GoogleFonts.poppins()),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Login', style: GoogleFonts.poppins(color: theme.colorScheme.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}