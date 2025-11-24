import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

// Navigation & Screens
import 'home_screen.dart';
import 'appointments_screen.dart';
import 'resources_screen.dart';
import 'support_screen.dart';
import 'bottom_nav_bar.dart';
import 'new_journal_entry_screen.dart';
import 'journal_detail_screen.dart';

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  State<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen> {
  final _searchController = TextEditingController();
  int _selectedIndex = 1;
  String _searchQuery = '';

  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())); break;
      case 1: break; 
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen())); break;
      case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResourcesScreen())); break;
      case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupportScreen())); break;
    }
  }

  void _openSentimentGraph() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SentimentGraphScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using the consistent soft background color
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        automaticallyImplyLeading: false,
        title: Text(
          'Journals',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.insights_rounded, color: Colors.indigo.shade600),
              tooltip: 'View Mood Trends',
              onPressed: _openSentimentGraph,
              style: IconButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search your thoughts...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.indigo.shade300),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: GoogleFonts.poppins(color: Colors.black87),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
          ),

          // 📖 Journal List
          Expanded(
            child: userId == null
                ? Center(
                    child: Text(
                      'Please log in to see your journals.',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ))
                : _JournalList(userId: userId!, searchQuery: _searchQuery),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewJournalEntryScreen()),
          );
        },
        backgroundColor: const Color(0xFF2563EB), // Professional Blue
        icon: const Icon(Icons.edit_note, color: Colors.white),
        label: Text("New Entry", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        elevation: 4,
      ),
      
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}

class _JournalList extends StatelessWidget {
  const _JournalList({required this.userId, required this.searchQuery});

  final String userId;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('journals')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading journals', style: GoogleFonts.poppins(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final entryText = (data['entry'] ?? '').toString().toLowerCase();
          final title = (data['title'] ?? '').toString().toLowerCase();
          return searchQuery.isEmpty ||
              entryText.contains(searchQuery) ||
              title.contains(searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No journal entries found.',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Space for FAB
          itemCount: filteredDocs.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final journal = doc.data() as Map<String, dynamic>;
            final entryText = journal['entry'] ?? '';
            final title = journal['title'] ?? 'Untitled entry';
            final createdAt = (journal['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
            final sentiment = journal['sentiment'] as Map<String, dynamic>?;

            return _JournalCard(
              docId: doc.id,
              title: title,
              entryText: entryText,
              createdAt: createdAt,
              sentiment: sentiment,
            );
          },
        );
      },
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.docId,
    required this.title,
    required this.entryText,
    required this.createdAt,
    this.sentiment,
  });

  final String docId;
  final String title;
  final String entryText;
  final DateTime createdAt;
  final Map<String, dynamic>? sentiment;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(createdAt);
    final formattedTime = DateFormat('h:mm a').format(createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JournalDetailScreen(
              id: docId,
              title: title,
              entry: entryText,
              createdAt: createdAt,
              sentiment: sentiment,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1C1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$formattedDate • $formattedTime",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                _SentimentIndicator(sentiment: sentiment),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entryText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Read Full Entry →",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentimentIndicator extends StatelessWidget {
  final Map<String, dynamic>? sentiment;
  const _SentimentIndicator({required this.sentiment});

  @override
  Widget build(BuildContext context) {
    // If analyzing/null, show subtle loader or empty
    if (sentiment == null || sentiment?['normalized'] == null) {
      return const SizedBox(width: 20); 
    }

    final normalized = (sentiment!['normalized'] as num).toDouble();
    String emoji = '😐';
    Color color = Colors.grey.shade200;

    if (normalized > 0.3) {
      emoji = '😄';
      color = Colors.green.shade50;
    } else if (normalized < -0.3) {
      emoji = '😢';
      color = Colors.red.shade50;
    } else {
      emoji = '😐';
      color = Colors.blue.shade50;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}

// 😊 Sentiment Analysis Graph (Styled Consistent with App)
class SentimentGraphScreen extends StatefulWidget {
  const SentimentGraphScreen({super.key});

  @override
  State<SentimentGraphScreen> createState() => _SentimentGraphScreenState();
}

class _SentimentGraphScreenState extends State<SentimentGraphScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _loading = true;
  List<FlSpot> _spots = [];
  List<DateTime> _entryDates = [];

  @override
  void initState() {
    super.initState();
    _loadSentimentData();
  }

  Future<void> _loadSentimentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final query = await _db.collection('journals')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('created_at')
          .get();

      if (query.docs.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final List<FlSpot> spots = [];
      final List<DateTime> entryDates = [];
      int idx = 0;
      for (var doc in query.docs) {
        final data = doc.data();
        if (data['created_at'] == null || data['sentiment'] == null) continue;
        final timestamp = data['created_at'] as Timestamp;
        final sentimentScore = (data['sentiment']['normalized'] ?? 0.0).toDouble();
        spots.add(FlSpot(idx.toDouble(), sentimentScore));
        entryDates.add(timestamp.toDate());
        idx++;
      }

      setState(() {
        _spots = spots;
        _entryDates = entryDates;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading sentiment graph: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Mood Trends',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _spots.isEmpty
              ? Center(child: Text("No data to display yet.", style: GoogleFonts.poppins()))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text("Sentiment per Entry", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 40),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            minY: -1.5,
                            maxY: 1.5,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.1),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value < 0 || value >= _entryDates.length) return const SizedBox();
                                    final date = _entryDates[value.toInt()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat.Md().format(date), // e.g. 11/23
                                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if(value == 1) return const Text("😄");
                                    if(value == 0) return const Text("😐");
                                    if(value == -1) return const Text("😢");
                                    return const SizedBox();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _spots,
                                isCurved: true,
                                color: Colors.indigo,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.indigo.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}