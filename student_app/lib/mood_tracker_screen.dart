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
          SnackBar(content: Text(errorMsg, style: GoogleFonts.poppins()), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to submit mood: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('Mood Tracker', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: theme.colorScheme.onSurface)),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'How are you feeling today?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 32.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_moodEmojis.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _moodValue = index + 1.0;
                          });
                        },
                        child: Text(
                          _moodEmojis[index],
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            color: _moodValue.round() == index + 1 ? theme.colorScheme.primary : theme.hintColor,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16.0),
                  Slider(
                    value: _moodValue,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: theme.colorScheme.primary,
                    label: _moodEmojis[_moodValue.round() - 1],
                    onChanged: (double value) {
                      setState(() {
                        _moodValue = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitMood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Submit Mood',
                            style: GoogleFonts.poppins(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
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