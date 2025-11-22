import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResourceDetailScreen extends StatelessWidget {
  final String title;
  final String body;

  const ResourceDetailScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Resource",
          style: GoogleFonts.poppins(
            color: Colors.black, 
            fontSize: 16, 
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            // Simulating a "tag" or meta info
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  "5 min read",
                  style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              body,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.8, // Better readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}