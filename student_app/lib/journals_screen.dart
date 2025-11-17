import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_screen.dart';
import 'appointments_screen.dart';
import 'resources_screen.dart';
import 'support_screen.dart';
import 'bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_journal_entry_screen.dart';
import 'journal_detail_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      case 1:
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const SupportScreen()));
        break;
    }
  }

  void _openSentimentGraph() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SentimentGraphScreen(userId: userId ?? '')),
    );
  }

  Future<void> _runBackfill() async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('backfillSentimentData');
      final result = await callable.call();
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.data['message'] ?? 'Processing started!')),
      );
    } on FirebaseFunctionsException catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unknown error occurred.')));
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
        title: Text(
          'Journals',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart, color: theme.colorScheme.primary),
            tooltip: 'View Sentiment Graph',
            onPressed: _openSentimentGraph,
          ),
          IconButton(
            icon: Icon(Icons.history, color: theme.colorScheme.secondary),
            tooltip: 'Analyze Old Entries',
            onPressed: _runBackfill,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search entries…',
                labelStyle: GoogleFonts.poppins(color: theme.hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.secondary),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              ),
              style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // 📖 Journal Entries
          Expanded(
            child: userId == null
                ? Center(
                    child: Text(
                  'Please log in to see your journals.',
                  style: GoogleFonts.poppins(),
                ))
                : _JournalList(userId: userId!, searchQuery: _searchQuery),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewJournalEntryScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('journals')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins()));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final entryText = (data['entry'] ?? '').toString().toLowerCase();
          final title = (data['title'] ?? '').toString().toLowerCase();
          final createdAt =
              (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
          final formattedDate =
              DateFormat('MMMM d, yyyy').format(createdAt).toLowerCase();
          return searchQuery.isEmpty ||
              entryText.contains(searchQuery) ||
              title.contains(searchQuery) ||
              formattedDate.contains(searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text('No journal entries found.',
                style: GoogleFonts.poppins(fontSize: 16, color: theme.hintColor)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80.0),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final journal = doc.data() as Map<String, dynamic>;
            final entryText = journal['entry'] ?? '';
            final title = journal['title'] ?? 'Untitled entry';
            final createdAt =
                (journal['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
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
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMMM d, yyyy').format(createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 2, // A subtle shadow like the support screen
        shadowColor: Colors.grey.shade200,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600, // Bolder title
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _SentimentIndicator(sentiment: sentiment),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entryText.split(' ').take(20).join(' ') +
                      (entryText.split(' ').length > 20 ? '...' : ''),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blueGrey.shade800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
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
                      child: Text(
                        'Read more',
                        style: GoogleFonts.poppins(
                          color: Colors.blue.shade700,
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
    );
  }
}

class _SentimentIndicator extends StatelessWidget {
  final Map<String, dynamic>? sentiment;
  const _SentimentIndicator({required this.sentiment});

  @override
  Widget build(BuildContext context) {
    // Show pending state if sentiment is null, has an error, or is missing the score.
    if (sentiment == null || sentiment?['error'] != null || sentiment?['normalized'] == null) {
      // Analyzing or Pending
      return const Text('🤔', style: TextStyle(fontSize: 20));
    }

    // At this point, we know sentiment and sentiment['normalized'] are not null.
    final normalized = (sentiment!['normalized'] as num).toDouble();

    if (normalized > 0.3) {
      return const Text('😄', style: TextStyle(fontSize: 20)); // Positive
    }
    if (normalized < -0.3) {
      return const Text('😢', style: TextStyle(fontSize: 20)); // Negative
    }
    return const Text('😐', style: TextStyle(fontSize: 20)); // Neutral
  }
}

/// ------------------ Sentiment Graph Screen ------------------
class SentimentGraphScreen extends StatelessWidget {
  final String? userId;
  const SentimentGraphScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentiment Over Time', style: GoogleFonts.poppins()),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: userId == null
          ? const Center(child: Text('User not logged in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journals')
                  .where('user_id', isEqualTo: userId)
                  .orderBy('created_at')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint("Graph Error: ${snapshot.error}");
                  return const Center(
                      child: Text(
                          'Error loading data. A Firestore index might be missing.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                      child: Text('Write a journal to see your sentiment graph.',
                          style: GoogleFonts.poppins()));
                }

                final List<FlSpot> spots = [];
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final sentimentData = data['sentiment'] as Map<String, dynamic>?;

                  // ✅ Check if sentiment data is valid and contains the 'normalized' value.
                  if (sentimentData != null &&
                      sentimentData['normalized'] is num &&
                      data['created_at'] is Timestamp) {
                        
                    final sentiment = (sentimentData['normalized'] as num).toDouble();
                    final timestamp =
                        (data['created_at'] as Timestamp).millisecondsSinceEpoch.toDouble();
                    spots.add(FlSpot(timestamp, sentiment));
                  }
                }

                if (spots.isEmpty) {
                  return Center(
                      child: Text('No entries with sentiment data found.',
                          style: GoogleFonts.poppins()));
                }

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              String text = '';
                              if (value == 1) text = '😄';
                              if (value == 0) text = '😐';
                              if (value == -1) text = '😢';
                              return Text(text, style: const TextStyle(fontSize: 20));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final date =
                                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(DateFormat.Md().format(date)),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 4,
                          color: theme.colorScheme.primary,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.4),
                                theme.colorScheme.primary.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      minY: -1.1,
                      maxY: 1.1,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
