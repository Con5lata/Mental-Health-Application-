import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'bottom_nav_bar.dart';
import 'journals_screen.dart';
import 'resources_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final appointmentQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date')
        .limit(1)
        .get();

    setState(() {
      _userName = userDoc.data()?['name'];
      if (appointmentQuery.docs.isNotEmpty) {
        final appointment = appointmentQuery.docs.first;
        _nextAppointment = appointment.data();

        final appointmentDate = _parseAppointmentDate(_nextAppointment?['date']);
        if (appointmentDate != null) {
          // Schedule a notification 1 hour before the appointment
          final reminderTime = appointmentDate.subtract(const Duration(hours: 1));
          if (reminderTime.isAfter(DateTime.now())) {
            NotificationService().scheduleNotification(
              id: appointment.id.hashCode, // Unique ID for the notification
              title: 'Appointment Reminder',
              body: "You have an appointment with ${_nextAppointment!['with']} in one hour.",
              scheduledTime: reminderTime,
            );
          }
        }
        _nextAppointment = appointmentQuery.docs.first.data();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final appointmentDate =
        _parseAppointmentDate(_nextAppointment?['date']);
    final formattedDate = appointmentDate != null
        ? "${_formatDate(appointmentDate)} at ${_formatTime(appointmentDate)}"
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: const Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _userName ?? user?.displayName ?? 'Welcome!',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.primary),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// NEXT APPOINTMENT CARD
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AppointmentsScreen()));
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
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              formattedDate ?? "No upcoming appointments",
                              style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                            ),
                            if (_nextAppointment?['with'] != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                "With: ${_nextAppointment!['with']}",
                                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13),
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

              const SizedBox(height: 10),
              Text("Links",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              /// GRID LINKS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  _buildNavCard(context, Icons.book_outlined, 'Journals', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const JournalsScreen()));
                  }, Colors.blue),
                  _buildNavCard(
                      context, Icons.calendar_today_outlined, 'Appointments',
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const AppointmentsScreen()));
                      }, Colors.green),
                  _buildNavCard(context, Icons.lightbulb_outline, 'Resources',
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ResourcesScreen()));
                      }, Colors.orange),
                  _buildNavCard(context, Icons.support_agent_outlined, 'Support',
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SupportScreen()));
                      }, Colors.purple),
                ],
              ),

              const SizedBox(height: 24),
              ProgressTracker(),
              const SizedBox(height: 10),
              ContactSupportBanner(),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  /// NAVIGATION HANDLER
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const JournalsScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ResourcesScreen()));
        break;
      case 4:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SupportScreen()));
        break;
    }
  }

  /// DATE HELPERS
  DateTime? _parseAppointmentDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

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

  Widget _buildNavCard(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onTap,
      Color color,
      ) { 
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

/// -------------------------------
/// EXTRA WIDGETS
/// -------------------------------

class ProgressTracker extends StatelessWidget {
  const ProgressTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final int completed = 3;
    final int total = 7;
    final double percent = completed / total;
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Progress',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface)),
                Text('$completed/$total days',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactSupportBanner extends StatelessWidget {
  const ContactSupportBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.5)),
      ),
      color: theme.colorScheme.secondary.withOpacity(0.08),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.support_agent_rounded,
                color: theme.colorScheme.secondary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Need help? Call the mental health hotline: +254 724 255 169',
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
