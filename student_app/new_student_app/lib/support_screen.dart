import 'package:flutter/material.dart';
import 'ask_anonymous_question_screen.dart';
import 'bottom_nav_bar.dart';
import 'home_screen.dart';
import 'journals_screen.dart';
import 'appointments_screen.dart';
import 'resources_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAF9),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Support & Q&A',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
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
                        style: TextStyle(color: Colors.red),
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Be the first to ask an anonymous question!",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
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
        label: const Text(
          'Ask Question',
          style: TextStyle(
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

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.97,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Question Text
                  Text(
                    widget.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15, // Slightly smaller
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
                        style: TextStyle(
                          fontSize: 12,
                          color: isOpen ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "By: Anonymous",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (dateStr.isNotEmpty)
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 💬 Response Bubble
                  AnimatedCrossFade(
                    firstChild: Text(
                      widget.response,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                    secondChild: Text(
                      widget.response,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
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
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Report',
                          style: const TextStyle(
                            color: Colors.red,
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
        ),
      ),
    );
  }
}

