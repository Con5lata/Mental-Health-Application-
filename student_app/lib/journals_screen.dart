import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Replace with FirebaseAuth.instance.currentUser!.uid in real use
  final String defaultUserId = '61xtbNAWg1gYxOH9lMCZ8u2Sxq23';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResourcesScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SupportScreen()),
        );
        break;
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Journals',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
            tooltip: 'New Entry',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewJournalEntryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar (same layout, added logic)
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 20.0,
                ),
              ),
              style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 🧠 Journal Entries (filtered by title, entry, or date)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journals')
                  .where('user_id', isEqualTo: defaultUserId)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins()),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // Filter results by search
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final entryText = (data['entry'] ?? '').toString().toLowerCase();
                  final createdAt =
                      (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final formattedDate =
                      DateFormat('MMMM d, yyyy').format(createdAt).toLowerCase();

                  // Title (first 5 words from entry)
                  final title = entryText.split(' ').take(5).join(' ');

                  return _searchQuery.isEmpty ||
                      entryText.contains(_searchQuery) ||
                      title.contains(_searchQuery) ||
                      formattedDate.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'No journal entries found.',
                      style: GoogleFonts.poppins(fontSize: 16, color: theme.hintColor),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final journal = doc.data() as Map<String, dynamic>;

                    final entryText = journal['entry'] ?? '';
                    final title =
                        entryText.toString().split(' ').take(5).join(' ');
                    final createdAt =
                        (journal['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final formattedDate =
                        DateFormat('MMMM d, yyyy').format(createdAt);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isNotEmpty ? title : 'Untitled entry',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entryText.split(' ').take(20).join(' ') +
                                    (entryText.split(' ').length > 20 ? '...' : ''),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JournalDetailScreen(
                                            id: doc.id,
                                            title: title,
                                            entry: entryText,
                                            createdAt: createdAt,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Read more',
                                      style: GoogleFonts.poppins(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
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
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewJournalEntryScreen(),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
