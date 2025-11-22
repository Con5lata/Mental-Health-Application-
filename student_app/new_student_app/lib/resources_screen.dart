import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_nav_bar.dart';
import 'home_screen.dart';
import 'journals_screen.dart';
import 'appointments_screen.dart';
import 'support_screen.dart';
import 'resources_detail_screen.dart';
import 'quiz_screen.dart'; // Import the quiz screen

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  String? _recommendedCategory; // Stores the result from the AI Quiz

  final Map<String, Color> categoryColors = {
    'All': Colors.blue.shade700,
    'Stress': Colors.red.shade400,
    'Anxiety': Colors.teal.shade400,
    'Exams': Colors.orange.shade400,
    'Burnout': Colors.purple.shade400,
    'Wellness': Colors.green.shade400,
  };

  void _takeQuiz() async {
    // Navigate to quiz and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        _recommendedCategory = result;
        selectedCategory = result; // Automatically filter by recommendation
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Based on your answers, we've highlighted $result resources."),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        title: Text(
          'Resources',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 24, 
            color: const Color(0xFF1A1C1E)
          ),
        ),
        centerTitle: false,
        actions: [
          if (_recommendedCategory != null)
            TextButton.icon(
              onPressed: () => setState(() {
                _recommendedCategory = null;
                selectedCategory = 'All';
              }),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Reset AI"),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Intro & Quiz Section
            if (_recommendedCategory == null)
              _buildIntroCard()
            else
              _buildRecommendationBanner(),

            const SizedBox(height: 20),

            // 2. Search Bar
            TextField(
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search articles, videos...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // 3. Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Stress', 'Anxiety', 'Exams', 'Burnout', 'Wellness'].map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      labelStyle: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      selected: isSelected,
                      selectedColor: categoryColors[cat] ?? Colors.blue,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.grey.shade200
                        )
                      ),
                      onSelected: (_) => setState(() => selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 4. Resource List
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
                  
                  final docs = snapshot.data?.docs ?? [];
                  
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    final category = data['category']?.toString().toLowerCase() ?? '';
                    
                    // Filter logic
                    final matchesSearch = title.contains(searchQuery);
                    final matchesCategory = selectedCategory == 'All' || 
                        category == selectedCategory.toLowerCase();
                    
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.content_paste_search, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text("No resources found", style: GoogleFonts.poppins(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
                      return ResourceCard(
                        title: data['title'] ?? 'Untitled',
                        body: data['body'] ?? '',
                        category: data['category'] ?? 'General',
                        color: categoryColors[data['category']] ?? Colors.blue,
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
            case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())); break;
            case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const JournalsScreen())); break;
            case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen())); break;
            case 3: break;
            case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupportScreen())); break;
          }
        },
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.yellowAccent),
              const SizedBox(width: 10),
              Text(
                "Personalized Care",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "At MindCare, we are committed to providing the best resources for your needs.",
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _takeQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Take the Quiz", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Results Analyzed",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                Text(
                  "Showing resources for: $_recommendedCategory",
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Refined Resource Card
class ResourceCard extends StatelessWidget {
  final String title;
  final String body;
  final String category;
  final Color color;

  const ResourceCard({
    super.key, 
    required this.title, 
    required this.body, 
    required this.category,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResourceDetailScreen(title: title, body: body)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                category.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "Read Article",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: Colors.blue.shade700),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}