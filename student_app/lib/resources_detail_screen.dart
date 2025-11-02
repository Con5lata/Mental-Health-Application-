import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResourceDetailScreen extends StatelessWidget {
  final String title;
  final String body;

  const ResourceDetailScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
        title: Text(
          'Resource Detail',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional date placeholder (or remove if not needed)
              // Chip(
              //   label: Text('November 2, 2025', style: GoogleFonts.poppins(fontSize: 13)),
              //   backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              // ),
              // const SizedBox(height: 16),

              // Title
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black)),
              const SizedBox(height: 16),

              // Body
              Text(body,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                      height: 1.6),
                  textAlign: TextAlign.justify),
              const SizedBox(height: 30),

              // Motivational footer
              Divider(color: Colors.grey.shade300, thickness: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.favorite_border,
                      color: theme.colorScheme.secondary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Take a deep breath — you’re doing great.',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.secondary.withOpacity(0.8),
                      fontSize: 13,
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
