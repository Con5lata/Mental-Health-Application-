import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'login_page.dart' as login_page;
import 'register_page.dart';
import 'mood_tracker_screen.dart';
import 'home_screen.dart';

/// =======================================================
///                      MAIN
/// =======================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://younrhmzkcywswzbmpds.supabase.co', // Your Supabase project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvdW5yaG16a2N5d3N3emJtcGRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NDA2NjUsImV4cCI6MjA3OTIxNjY2NX0.hpODtUEH8raRjcLS9ZkPcoPJ4UShxL63hiWzAzITyXQ',
  );

  runApp(const MyApp());
 //await seedDatabase(); // Uncomment to seed Firestore with resources (run ONCE)
}

/// ======================================================
///                      APP
/// =======================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Mental Health App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthWrapper(),
      routes: {
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

/// =======================================================
///                    AUTH WRAPPER
/// =======================================================
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _hasOpenedBefore;

  @override
  void initState() {
    super.initState();
    _hasOpenedBefore = _checkFirstTime();
  }

  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasOpened = prefs.getBool('hasOpenedBefore') ?? false;

    if (!hasOpened) {
      await prefs.setBool('hasOpenedBefore', true);
    }

    return hasOpened;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasOpenedBefore,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasOpened = snapshot.data ?? false;

        // FIRST TIME USERS → show LoginPage
        if (!hasOpened) {
          return const login_page.LoginPage();
        }

        // Return based on Firebase Auth state
        return StreamBuilder<firebase_auth.User?>(
          stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            final user = authSnapshot.data;

            if (user != null && user.emailVerified) {
              return const HomeScreen();
            }

            return const login_page.LoginPage();
          },
        );
      },
    );
  }
}

/// =======================================================
///             DAILY MOOD DECISION SCREEN
/// =======================================================
class DecisionScreen extends StatelessWidget {
  final String userId;
  const DecisionScreen({super.key, required this.userId});

  Future<bool> _hasSubmittedMoodToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final querySnapshot = await FirebaseFirestore.instance
          .collection('moods')
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking mood: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSubmittedMoodToday(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final submitted = snapshot.data ?? false;
        return submitted ? const HomeScreen() : const MoodTrackerScreen();
      },
    );
  }
}

/// =======================================================
///                          THEME
/// =======================================================
ThemeData buildAppTheme() {
  return ThemeData(
    fontFamily: 'Nunito Sans',
    primaryColor: const Color(0xFF0B52B5),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: const Color(0xFFE5E7EB),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
          fontSize: 32),
      titleLarge: TextStyle(
          color: Color(0xFF0B52B5),
          fontWeight: FontWeight.w700,
          fontSize: 24),
      bodyLarge: TextStyle(color: Color(0xFF1E293B), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF64748B), fontSize: 14),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0B52B5),
      secondary: Color(0xFF38B2AC),
      surface: Color(0xFFE5E7EB),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF1E293B),
      onSurface: Color(0xFF1E293B),
    ),
  );
}
