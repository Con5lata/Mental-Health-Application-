import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'bottom_nav_bar.dart';
import 'journals_screen.dart';
import 'resources_screen.dart';
import 'support_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String?> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.data()?['name'] ?? user.displayName ?? 'User';
    }
    return 'User';
  }
  Widget _buildNavGridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: theme.primaryColor),
              const SizedBox(height: 12),
              Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JournalsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResourcesScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SupportScreen()),
        );
        break;
    }
  }
  int _selectedIndex = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userName = doc.data()?['name'] ?? user.displayName ?? 'User';
      });
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
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text(
                (_userName != null && _userName!.isNotEmpty)
                  ? _userName!.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                  : 'U',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _userName ?? 'User',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.primary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ...existing code...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text('😞', style: TextStyle(fontSize: 32)),
                  Text('😐', style: TextStyle(fontSize: 32)),
                  Text('🙂', style: TextStyle(fontSize: 32)),
                  Text('😊', style: TextStyle(fontSize: 32)),
                  Text('😁', style: TextStyle(fontSize: 32)),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildNavGridItem(context, Icons.book_outlined, 'Journals', () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const JournalsScreen()));
                    }),
                    _buildNavGridItem(context, Icons.calendar_today_outlined, 'Appointments', () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppointmentsScreen()));
                    }),
                    _buildNavGridItem(context, Icons.lightbulb_outline, 'Resources', () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResourcesScreen()));
                    }),
                    _buildNavGridItem(context, Icons.support_agent_outlined, 'Support', () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Next Appointment', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monday, Nov 3 at 10:00 AM', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          FutureBuilder<String?>(
                            future: _getUserName(),
                            builder: (context, snapshot) {
                              final name = snapshot.data ?? 'User';
                              return Text(name, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}