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
      MaterialPageRoute(builder: (context) => const SentimentGraphScreen()),
    );
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
          style: const TextStyle(
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
                labelStyle: TextStyle(color: theme.hintColor),
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
              style: TextStyle(color: theme.colorScheme.onSurface),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // 📖 Journal Entries
          Expanded(
            child: userId == null
                ? Center(
                    child: Text(
                  'Please log in to see your journals.',
                  style: const TextStyle(),
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
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle()));
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
            child: Text('No journal entries found.', style: TextStyle(fontSize: 16, color: theme.hintColor)),
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
    final formattedDate = DateFormat('MMMM d, yyyy').format(createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0), // Reduced horizontal and vertical padding
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500, // Increase max width for less crowding
            minWidth: 350, // Ensure card is wider on larger screens
            minHeight: 80, // Reduce min height for a more compact card
          ),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            elevation: 2,
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
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0), // Reduced card inner padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Allow card to shrink vertically
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15, // Slightly smaller title
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        _SentimentIndicator(sentiment: sentiment),
                      ],
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    Text(
                      entryText.split(' ').take(20).join(' ') +
                          (entryText.split(' ').length > 20 ? '...' : ''),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12, color: Colors.grey,
                          ),
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
                          child: const Text(
                            'Read more',
                            style: TextStyle(
                              color: Colors.blue,
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
// 😊 Sentiment Analysis Graph

class SentimentGraphScreen extends StatefulWidget {
  const SentimentGraphScreen({super.key});

  @override
  State<SentimentGraphScreen> createState() => _SentimentGraphScreenState();
}

class _SentimentGraphScreenState extends State<SentimentGraphScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _loading = true;
  List<FlSpot> _spots = [];
  List<DateTime> _sortedDays = [];

  @override
  void initState() {
    super.initState();
    _loadSentimentData();
  }

  Future<void> _loadSentimentData() async {
    try {
      final query = await _db.collection('journals').get();

      if (query.docs.isEmpty) {
        setState(() {
          _loading = false;
        });
        return;
      }

      // Map of day → list of sentiment scores
      final Map<int, List<double>> dailyScores = {};

      for (var doc in query.docs) {
        final data = doc.data();

        if (data['created_at'] == null || data['sentiment'] == null) continue;

        final timestamp = data['created_at'] as Timestamp;
        final day = DateTime(timestamp.toDate().year,
            timestamp.toDate().month, timestamp.toDate().day);
        final dayKey = day.millisecondsSinceEpoch;

        final sentimentScore =
            (data['sentiment']['normalized'] ?? 0.0).toDouble();

        dailyScores.putIfAbsent(dayKey, () => []);
        dailyScores[dayKey]!.add(sentimentScore);
      }

      _sortedDays = dailyScores.keys
          .map((e) => DateTime.fromMillisecondsSinceEpoch(e))
          .toList()
        ..sort((a, b) => a.compareTo(b));

      final List<FlSpot> spots = [];

      for (int i = 0; i < _sortedDays.length; i++) {
        final day = _sortedDays[i];
        final key =
            DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;

        final scores = dailyScores[key]!;
        final avg = scores.reduce((a, b) => a + b) / scores.length;

        spots.add(FlSpot(i.toDouble(), avg));
      }

      setState(() {
        _spots = spots;
        _loading = false;
      });
    } catch (e) {
      print("Error loading sentiment graph: $e");
      setState(() => _loading = false);
    }
  }

  String _emojiForValue(double value) {
    if (value > 0.3) return "😄";
    if (value >= -0.3) return "😐";
    return "😢";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mood Trend',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _spots.isEmpty
              ? const Center(
                  child: Text(
                    "No sentiment data available yet.",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                  
                      minY: -2.0,
                      maxY: 2.0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots,
                          isCurved: true,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 ||
                                  value >= _sortedDays.length) {
                                return const SizedBox.shrink();
                              }
                              final date = _sortedDays[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat.E().format(date),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 0.5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _emojiForValue(value),
                                style: const TextStyle(fontSize: 20),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
    );
  }
}

