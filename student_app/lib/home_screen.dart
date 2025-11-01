import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'bottom_nav_bar.dart';
import 'journals_screen.dart';
import 'resources_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _userName;
  Map<String, dynamic>? _nextAppointment;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// ✅ Fetch user details & next appointment
  Future<void> _fetchUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    if (mounted) setState(() => _userName = 'User');
    return;
  }

  try {
    // 🔍 Query user doc where 'user_id' matches the current Firebase Auth UID
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      final nameFromDb = data['name']?.toString().trim();

      // ✅ Prefer name from Firestore if available
      if (nameFromDb != null && nameFromDb.isNotEmpty) {
        if (mounted) setState(() => _userName = nameFromDb);
      } else {
        // Fall back to display name or email prefix
        final fallbackName = user.displayName?.split(' ').first ??
            user.email?.split('@').first ??
            'User';
        if (mounted) setState(() => _userName = fallbackName);
      }
    } else {
      // No document found, use fallback
      final fallbackName = user.displayName?.split(' ').first ??
          user.email?.split('@').first ??
          'User';
      if (mounted) setState(() => _userName = fallbackName);
    }

    // 🔹 Fetch next upcoming appointment
    final appointmentsQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('date', descending: false)
        .limit(1)
        .get();

    if (appointmentsQuery.docs.isNotEmpty) {
      if (mounted) {
        setState(() => _nextAppointment = appointmentsQuery.docs.first.data());
      }
    } else {
      if (mounted) setState(() => _nextAppointment = null);
    }
  } catch (e, st) {
    print('Error fetching user data: $e\n$st');
    if (mounted) {
      setState(() {
        _userName = user.email?.split('@').first ?? 'User';
      });
    }
  }
}


  /// ✅ Handle bottom navigation
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const JournalsScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ResourcesScreen()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SupportScreen()));
        break;
    }
  }

  /// ✅ Helper to build cards for navigation
  Widget _buildNavCard(BuildContext context, IconData icon, String label,
      VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        color: color.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 10),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Parse Firestore Timestamp/Date
  DateTime? _parseAppointmentDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// ✅ Build UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = (_userName != null && _userName!.isNotEmpty)
        ? _userName!.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    final appointmentDate = _parseAppointmentDate(_nextAppointment?['date']);
    final formattedDate = appointmentDate != null
        ? "${_formatDate(appointmentDate)} at ${_formatTime(appointmentDate)}"
        : null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        title: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.primaryColor,
              child: Text(initials,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Hi, ${_userName ?? 'User'}",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Next Appointment Card
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Next Appointment",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              formattedDate ?? "No upcoming appointments",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[700], fontSize: 14),
                            ),
                            if (_nextAppointment?['with'] != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                "With: ${_nextAppointment!['with']}",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.blueAccent, size: 20),
                    ],
                  ),
                ),
              ),

              // ✅ Topics Section
              const SizedBox(height: 10),
              Text("Links",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  _buildNavCard(context, Icons.book_outlined, 'Journals', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const JournalsScreen()));
                  }, Colors.blue),
                  _buildNavCard(context, Icons.calendar_today_outlined, 'Appointments', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
                  }, Colors.green),
                  _buildNavCard(context, Icons.lightbulb_outline, 'Resources', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ResourcesScreen()));
                  }, Colors.orange),
                  _buildNavCard(context, Icons.support_agent_outlined, 'Support', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SupportScreen()));
                  }, Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  /// ✅ Date Formatting Helpers
  String _formatDate(DateTime d) {
    return "${_monthShort(d.month)} ${d.day}, ${d.year}";
  }

  String _formatTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $ampm";
  }

  String _monthShort(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}
