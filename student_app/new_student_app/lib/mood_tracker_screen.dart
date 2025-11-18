import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  double _moodValue = 3.0;
  final List<String> _moodEmojis = ['😞', '😐', '🙂', '😊', '😁'];
  bool _isSubmitting = false;

  Future<void> _submitMood() async {
    final user = FirebaseAuth.instance.currentUser;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (user == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('No user logged in!', style: GoogleFonts.poppins())),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final moodData = {
        'user_id': user.uid,
        'note': _moodEmojis[_moodValue.round() - 1],
        'score': _moodValue.round(),
        'date': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('moods').add(moodData);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Mood submitted successfully!', style: GoogleFonts.poppins())),
        );

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        String errorMsg = e.message ?? 'Failed to submit mood.';
        if (e.code == 'permission-denied') {
          errorMsg = 'Permission denied: Please check your Firestore rules.';
        }
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to submit mood: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Mood Tracker',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F8FC), Color(0xFFEDEFF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              children: [
                // 💬 Welcome Text
                Text(
                  "How are you feeling today?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),

                // 🪞 Mood Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 4,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // 😊 Emoji Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_moodEmojis.length, (index) {
                          final isSelected = _moodValue.round() == index + 1;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _moodValue = index + 1.0);
                            },
                            child: AnimatedScale(
                              scale: isSelected ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _moodEmojis[index],
                                style: TextStyle(
                                  fontSize: 38,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.grey[500],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      // 🎚️ Slider
                      Slider(
                        value: _moodValue,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        activeColor: theme.colorScheme.primary,
                        label: _moodEmojis[_moodValue.round() - 1],
                        onChanged: (double value) {
                          setState(() => _moodValue = value);
                        },
                      ),

                      const SizedBox(height: 32),

                      // 💾 Submit button
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitMood,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 22.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  "Save My Mood",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // 🌤️ Footer message
                Text(
                  "Remember, your feelings matter 💙",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
