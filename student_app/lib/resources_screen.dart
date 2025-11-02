import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'home_screen.dart';
import 'journals_screen.dart';
import 'appointments_screen.dart';
import 'support_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String selectedCategory = 'All';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final Map<String, Color> categoryColors = {
    'All': Colors.blue.shade700,
    'Stress': Colors.red.shade400,
    'Exams': Colors.orange.shade400,
    'Burnout': Colors.purple.shade400,
  };

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
            'Resources',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search resources...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.poppins(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            // 🏷️ Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Stress', 'Exams', 'Burnout'].map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat,
                          style: GoogleFonts.poppins(
                              color: selectedCategory == cat
                                  ? Colors.white
                                  : categoryColors[cat] ?? Colors.blue.shade700,
                              fontWeight: FontWeight.w500)),
                      selected: selectedCategory == cat,
                      selectedColor: categoryColors[cat] ?? Colors.blue.shade700,
                      backgroundColor: (categoryColors[cat] ?? Colors.blue.shade700)
                          .withOpacity(0.1),
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // 📄 Firestore resource list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('resources')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Error loading resources',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  // Apply search and category filters
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    final body = data['body']?.toString().toLowerCase() ?? '';
                    final category =
                        data['category']?.toString().toLowerCase() ?? '';
                    final matchesSearch =
                        title.contains(searchQuery) || body.contains(searchQuery);
                    final matchesCategory = selectedCategory.toLowerCase() == 'all'
                        ? true
                        : category == selectedCategory.toLowerCase();
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open,
                              size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('No resources found',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, color: Colors.grey.shade600)),
                        ],
                      ),
                    );
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            filteredDocs[index].data() as Map<String, dynamic>;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ResourceCard(
                            title: data['title'] ?? '',
                            body: data['body'] ?? '',
                          ),
                        );
                      },
                    ),
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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
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
              // Already on ResourcesScreen
              break;
            case 4:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SupportScreen()));
              break;
          }
        },
      ),
    );
  }
}

// 📝 Resource Card - opens semi-full page modal on "Read more"
// 📝 Resource Card - opens semi-full page modal on "Read more"
class ResourceCard extends StatelessWidget {
  final String title;
  final String body;

  const ResourceCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black)),
            const SizedBox(height: 8),
            Stack(
              children: [
                // Removed shade here
                Text(body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.white])),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResourceDetailScreen(title: title, body: body),
                      ),
                    );
                  },
                  child: Text('Read more',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700)),
                ),
            ),
          ],
        ),
      ),
    );
  }
}


// 📑 Semi-full page modal for resource detail
class ResourceDetailScreen extends StatelessWidget {
  final String title;
  final String body;

  const ResourceDetailScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black)),
              const SizedBox(height: 16),
              Text(body,
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.blueGrey.shade800)),
            ],
          ),
        ),
      ),
    );
  }
}
