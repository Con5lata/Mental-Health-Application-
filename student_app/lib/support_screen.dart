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
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAF9),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Support & Q&A',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💬 Contextual header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Need guidance or have something on your mind? "
                "Ask your questions anonymously, and our counsellors will respond here.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blueGrey.shade700,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // 💡 Firestore Q&A List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('qna')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading Q&A. Please try again.',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        key: const ValueKey('empty'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 70, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No questions yet",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Be the first to ask an anonymous question!",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    key: const ValueKey('list'),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return QAExpandableCard(
                        question: data['question'] ?? '',
                        response: data['response'] ?? 'No response yet.',
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
      // ✅ Floating Ask Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: Text(
          'Ask Question',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const AskAnonymousQuestionScreen()),
          );
        },
      ),
      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const JournalsScreen()));
              break;
            case 2:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppointmentsScreen()));
              break;
            case 3:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ResourcesScreen()));
              break;
            case 4:
              // Already on SupportScreen
              break;
          }
        },
      ),
    );
  }
}

// 🧩 Stateful Q&A Card Component
class QAExpandableCard extends StatefulWidget {
  final String question;
  final String response;
  final String? status;
  final dynamic createdAt;

  const QAExpandableCard({
    super.key,
    required this.question,
    required this.response,
    this.status,
    this.createdAt,
  });

  @override
  State<QAExpandableCard> createState() => _QAExpandableCardState();
}

class _QAExpandableCardState extends State<QAExpandableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    if (widget.createdAt is Timestamp) {
      final dt = (widget.createdAt as Timestamp).toDate();
      dateStr =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    final isOpen = widget.status == 'open';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Question Text
              Text(
                widget.question,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // 🔸 Meta info
              Row(
                children: [
                  Icon(
                    isOpen ? Icons.mark_chat_unread : Icons.mark_chat_read,
                    size: 16,
                    color: isOpen ? Colors.green : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOpen ? "Open" : "Answered",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isOpen ? Colors.green : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "By: Anonymous",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 💬 Response Bubble
              AnimatedCrossFade(
                firstChild: Text(
                  widget.response,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                secondChild: Text(
                  widget.response,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              const SizedBox(height: 8),
              // Action buttons
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Text(
                      isExpanded ? 'Show less' : 'View full answer',
                      style: GoogleFonts.poppins(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Report',
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
