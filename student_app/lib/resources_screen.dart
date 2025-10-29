import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'home_screen.dart';
import 'journals_screen.dart';
import 'appointments_screen.dart';
import 'support_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

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
          child: Text('Resources', style: theme.textTheme.titleLarge),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(theme),
            const SizedBox(height: 16),
            _categoryFilters(theme),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('resources').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading resources'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(child: Text('No resources found', style: GoogleFonts.poppins(fontSize: 16)));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, idx) {
                      final data = docs[idx].data() as Map<String, dynamic>;
                      final creatorId = data['created_by'] ?? '';
                      return SizedBox(
                        width: double.infinity,
                        child: FutureBuilder<DocumentSnapshot>(
                          future: creatorId.isNotEmpty
                              ? FirebaseFirestore.instance.collection('users').doc(creatorId).get()
                              : Future.value(FirebaseFirestore.instance.collection('users').doc('dummy').get()),
                          builder: (context, snapshot) {
                            String creatorName = 'Unknown';
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                              final userData = snapshot.data!.data() as Map<String, dynamic>?;
                              creatorName = userData?['name'] ?? 'Unknown';
                            } else if (creatorId.isEmpty) {
                              creatorName = 'Anonymous';
                            }
                            return _resourceCard(
                              theme,
                              data['title'] ?? '',
                              data['body'] ?? '',
                              data['category'] ?? '',
                              creatorName,
                              data['created_at'],
                              data['views'] ?? 0,
                            );
                          },
                        ),
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
        currentIndex: 3,
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
              // Already on ResourcesScreen
              break;
            case 4:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const SupportScreen()));
              break;
          }
        },
      ),
    );
  }

  Widget _searchBar(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search resources...',
        hintStyle: GoogleFonts.poppins(color: theme.hintColor),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.secondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
    );
  }

  Widget _categoryFilters(ThemeData theme) {
    final categories = ['All', 'Stress', 'Exams', 'Burnout'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(cat, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface)),
            selected: cat == 'All',
            selectedColor: theme.colorScheme.secondary,
            backgroundColor: theme.colorScheme.surface,
            onSelected: (_) {},
          ),
        );
      }).toList(),
    );
  }

  Widget _resourceCard(
    ThemeData theme,
    String title,
    String body,
    String category,
    String createdBy,
    dynamic createdAt,
    int views,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title by $createdBy', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 19, color: Colors.blue[900])),
            const SizedBox(height: 8),
            Text(body, style: GoogleFonts.poppins(fontSize: 15, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(category, style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue[900])),
                  backgroundColor: Colors.blue[50],
                ),
                const SizedBox(width: 12),
                Text('By $createdBy', style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue[900])),
                const SizedBox(width: 12),
                Text('Views: $views', style: GoogleFonts.poppins(fontSize: 13, color: Colors.blue[900])),
              ],
            ),
            const SizedBox(height: 10),
            Text('Created: ${_formatDate(createdAt)}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[700])),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                onPressed: () {},
                child: const Text('Read more'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    return createdAt.toString();
  }
}
