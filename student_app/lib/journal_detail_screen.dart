import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalDetailScreen extends StatefulWidget {
  final String id; // Firestore document ID
  final String title;
  final String entry;
  final DateTime createdAt;

  const JournalDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.entry,
    required this.createdAt,
  });

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late bool isEditing;
  late TextEditingController titleController;
  late TextEditingController entryController;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    titleController = TextEditingController(text: widget.title);
    entryController = TextEditingController(text: widget.entry);
  }

  @override
  void dispose() {
    titleController.dispose();
    entryController.dispose();
    super.dispose();
  }

  Future<void> _updateJournal() async {
    try {
      await FirebaseFirestore.instance.collection('journals').doc(widget.id).update({
        'title': titleController.text.trim(),
        'entry': entryController.text.trim(),
        'updatedAt': DateTime.now(),
      });

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error updating journal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update journal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteJournal() async {
    try {
      await FirebaseFirestore.instance.collection('journals').doc(widget.id).delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal deleted successfully.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting journal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete journal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMMM d, yyyy').format(widget.createdAt);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Journal Entry',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          // 🗑️ Delete Icon
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Journal'),
                  content: const Text('Are you sure you want to delete this entry?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Delete'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );
              if (confirm == true) _deleteJournal();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Hero(
          tag: widget.id, // unique hero tag
          child: Material(
            color: Colors.transparent,
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
                  // 🩶 Date Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🖋️ Editable Title
                  isEditing
                      ? TextField(
                          controller: titleController,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter title...',
                            border: InputBorder.none,
                          ),
                        )
                      : Text(
                          titleController.text.isNotEmpty
                              ? titleController.text
                              : 'Untitled entry',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                  const SizedBox(height: 16),

                  // ✍🏽 Editable Journal Body
                  isEditing
                      ? TextField(
                          controller: entryController,
                          style: GoogleFonts.poppins(fontSize: 16),
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write your thoughts...',
                          ),
                        )
                      : Text(
                          entryController.text,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                  const SizedBox(height: 30),

                  // 🌸 Gentle Divider + Emotion Tag Area
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
        ),
      ),

      // ✏️ Floating Edit / Save Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(isEditing ? Icons.check : Icons.edit),
        label: Text(
          isEditing ? 'Save' : 'Edit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        onPressed: () {
          if (isEditing) {
            _updateJournal(); // save changes
          } else {
            setState(() {
              isEditing = true; // toggle edit mode
            });
          }
        },
      ),
    );
  }
}
