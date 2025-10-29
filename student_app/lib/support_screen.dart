import 'package:flutter/material.dart';
import 'ask_anonymous_question_screen.dart';
import 'bottom_nav_bar.dart';
import 'home_screen.dart';
import 'journals_screen.dart';
import 'appointments_screen.dart';
import 'resources_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
          child: Text('Support & Q&A', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 26, color: theme.colorScheme.onSurface)),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AskAnonymousQuestionScreen()),
                  );
                },
                child: Text('Ask an Anonymous Question', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('qna')
          .orderBy('created_at', descending: true)
          .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading Q&A'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(child: Text('No questions yet.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _qaCard(
                        theme,
                        question: data['question'] ?? '',
                        response: data['response'] ?? 'No response yet.',
                        authorId: data['author_id'] ?? '',
                        status: data['status'] ?? '',
                        createdAt: data['created_at'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const JournalsScreen()));
              break;
            case 2:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const AppointmentsScreen()));
              break;
            case 3:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const ResourcesScreen()));
              break;
            case 4:
              // Already on SupportScreen
              break;
          }
        },
      ),
    );
  }

  Widget _qaCard(
    ThemeData theme, {
    required String question,
    required String response,
    String? authorId,
    String? status,
    dynamic createdAt,
  }) {
    String dateStr = '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('By: Anonymous', style: GoogleFonts.poppins(fontSize: 13, color: theme.hintColor)),
                const SizedBox(width: 12),
                if (dateStr.isNotEmpty)
                  Text(dateStr, style: GoogleFonts.poppins(fontSize: 13, color: theme.hintColor)),
                const SizedBox(width: 12),
                if (status != null && status.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: status == 'open' ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(status, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(response, style: GoogleFonts.poppins(fontSize: 15, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('View full answer', style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('Report', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
