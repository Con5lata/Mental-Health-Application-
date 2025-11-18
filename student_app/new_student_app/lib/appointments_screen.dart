import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'bottom_nav_bar.dart';
import 'request_appointment_screen.dart';
import 'home_screen.dart';
import 'journals_screen.dart';
import 'resources_screen.dart';
import 'support_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final appointmentsRef = FirebaseFirestore.instance
        .collection('appointments')
        .where('student_id', isEqualTo: user?.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAF9),
        title: Text(
          'Appointments',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsRef.orderBy('slot', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle no appointments
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _noAppointmentsCard(context),
                  const SizedBox(height: 24),
                  _requestAppointmentButton(context),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final upcoming = snapshot.data!.docs.where((doc) {
            final slot = (doc['slot'] as Timestamp).toDate();
            return slot.isAfter(now);
          }).toList();

          final past = snapshot.data!.docs.where((doc) {
            final slot = (doc['slot'] as Timestamp).toDate();
            return slot.isBefore(now);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (upcoming.isNotEmpty)
                  _upcomingCard(context, upcoming.first)
                else
                  _noAppointmentsCard(context),
                const SizedBox(height: 24),

                _requestAppointmentButton(context),
                const SizedBox(height: 28),

                Text(
                  'Past Appointments',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: past.isEmpty
                      ? Center(
                          child: Text(
                            "No past appointments.",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: past.length,
                          itemBuilder: (context, index) {
                            final doc = past[index];
                            return _pastAppointmentCard(context, doc);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),

      // Bottom Nav
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const JournalsScreen()));
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const ResourcesScreen()));
              break;
            case 4:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const SupportScreen()));
              break;
          }
        },
      ),
    );
  }

  // 💡 Empty state card
  Widget _noAppointmentsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, color: Colors.blue.shade400, size: 50),
          const SizedBox(height: 12),
          Text(
            "No appointments yet",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You haven’t scheduled any counselling sessions yet.\nTap below to request one.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Request Appointment Button
  Widget _requestAppointmentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RequestAppointmentPage()),
          );
        },
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text(
          'Request Appointment',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // 🧩 Upcoming Appointment Card
  Widget _upcomingCard(BuildContext context, QueryDocumentSnapshot doc) {
    final slot = (doc['slot'] as Timestamp).toDate();
    final formattedDate = DateFormat('EEE, MMM d · hh:mm a').format(slot);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 26,
            child: Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upcoming Appointment",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.blue.shade900,
                  ),
                ),
                Text(
                  doc['reason'] ?? 'Counselling Session',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              (doc['status'] ?? '').toString().capitalize(),
            ),
            backgroundColor: doc['status'] == 'pending'
                ? Colors.orange.shade400
                : Colors.blue.shade700,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Past Appointment Card
  Widget _pastAppointmentCard(BuildContext context, QueryDocumentSnapshot doc) {
    final slot = (doc['slot'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, yyyy').format(slot);

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade50,
          child: Icon(Icons.person, color: Colors.blue.shade700),
        ),
        title: Text(
          formattedDate,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            doc['reason'] ?? 'Counselling Session',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
        trailing: Chip(
          label: const Text("Completed"),
          backgroundColor: Colors.grey.shade300,
          labelStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// 🔠 Helper extension
extension StringCasingExtension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
