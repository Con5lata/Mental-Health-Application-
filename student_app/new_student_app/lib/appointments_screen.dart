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
        .where('user_id', isEqualTo: user?.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Very soft grey background
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        automaticallyImplyLeading: false,
        title: Text(
          'Appointments',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsRef.orderBy('slot', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading appointments"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
          
          // Filter Lists
          final upcoming = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['slot'] == null) return false;
            final slot = (data['slot'] as Timestamp).toDate();
            return slot.isAfter(now);
          }).toList();

          final past = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['slot'] == null) return false;
            final slot = (data['slot'] as Timestamp).toDate();
            return slot.isBefore(now);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              if (upcoming.isNotEmpty) ...[
                Text(
                  "UPCOMING",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                // Using the new expandable card
                ExpandableAppointmentCard(doc: upcoming.first),
              ] else 
                _noAppointmentsCard(context),
              
              const SizedBox(height: 24),

              _requestAppointmentButton(context),
              const SizedBox(height: 32),

              if (past.isNotEmpty) ...[
                Text(
                  "HISTORY",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                ...past.map((doc) => _pastAppointmentCard(context, doc)),
              ],
            ],
          );
        },
      ),

      // Bottom Nav
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())); break;
            case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const JournalsScreen())); break;
            case 2: break; 
            case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResourcesScreen())); break;
            case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupportScreen())); break;
          }
        },
      ),
    );
  }

  Widget _noAppointmentsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 16),
          Text(
            "No upcoming sessions",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Schedule a time to talk with someone.",
            style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _requestAppointmentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB), // Professional Blue
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RequestAppointmentPage()),
          );
        },
        child: Text(
          'Request New Appointment',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _pastAppointmentCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final slot = (data['slot'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, y').format(slot);
    final formattedTime = DateFormat('h:mm a').format(slot);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle_outline, color: Colors.grey.shade400, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "$formattedTime • Completed",
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------
/// NEW EXPANDABLE CARD WIDGET
/// This handles the "Read More" and subtle status logic
/// ---------------------------------------------------
class ExpandableAppointmentCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const ExpandableAppointmentCard({super.key, required this.doc});

  @override
  State<ExpandableAppointmentCard> createState() => _ExpandableAppointmentCardState();
}

class _ExpandableAppointmentCardState extends State<ExpandableAppointmentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final slot = (data['slot'] as Timestamp).toDate();
    
    final dayStr = DateFormat('d').format(slot);
    final monthStr = DateFormat('MMM').format(slot);
    final timeStr = DateFormat('h:mm a').format(slot);
    final fullDateStr = DateFormat('EEEE, MMMM d, y').format(slot);
    
    final status = (data['status'] ?? 'Pending').toString().trim().capitalize();
    final reason = data['reason'] ?? 'No details provided.';
    
    final isApproved = status.toLowerCase() == 'approved';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOP ROW: Date Block & Time ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date Block
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayStr,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          height: 1,
                        ),
                      ),
                      Text(
                        monthStr.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                
                // Time & Context
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeStr,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        fullDateStr,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- EXPANDABLE SECTION (Reason) ---
          if (_isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reason for Appointment",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reason,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // --- BOTTOM ACTION ROW ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Subtle Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isApproved ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2)
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.access_time_filled,
                        size: 14,
                        color: isApproved ? Colors.green.shade700 : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isApproved ? Colors.green.shade700 : Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Read More / Less Button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? "Show Less" : "Read More",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}