import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalDetailScreen extends StatefulWidget {
  final String id; // Firestore document ID
  final String title;
  final String entry;
  final DateTime createdAt;
  final Map<String, dynamic>? sentiment;

  const JournalDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.entry,
    required this.createdAt,
    this.sentiment,
  });

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
    String? _aiFeedback;
    bool _loadingFeedback = false;
  late bool isEditing;
  late TextEditingController titleController;
  late TextEditingController entryController;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    titleController = TextEditingController(text: widget.title);
    entryController = TextEditingController(text: widget.entry);
    _fetchAIFeedback();
  }

  Future<void> _fetchAIFeedback() async {
    setState(() {
      _loadingFeedback = true;
    });
    try {
      final doc = await FirebaseFirestore.instance.collection('journals').doc(widget.id).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['ai_feedback'] != null && data['ai_feedback'].toString().trim().isNotEmpty) {
          setState(() {
            _aiFeedback = data['ai_feedback'].toString();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching AI feedback: $e');
    } finally {
      setState(() {
        _loadingFeedback = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    entryController.dispose();
    super.dispose();
  }

  Future<void> _updateJournal() async {
    // Prepare the data to update, preserving the existing sentiment if available.
    final Map<String, dynamic> updateData = {
      'title': titleController.text.trim(),
      'entry': entryController.text.trim(),
      'updatedAt': DateTime.now(),
    };

    try {
      // Use `set` with `merge: true` to safely update the document
      // without overwriting existing fields like 'sentiment' or 'tags'.
      await FirebaseFirestore.instance.collection('journals').doc(widget.id).set(updateData, SetOptions(merge: true));

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

  Widget _buildSentimentChip() {
    // If sentiment is null or has a 'pending' status, show Analyzing/Pending.
    if (widget.sentiment == null) {
      return const Chip(
          label: Text('🤔 Analyzing...'), backgroundColor: Color(0xFFE0E0E0));
    }

    if (widget.sentiment!['status'] == 'pending' ||
        widget.sentiment!['error'] != null ||
        widget.sentiment!['normalized'] == null) {
      return const Chip(
          label: Text('🤔 Pending...'), backgroundColor: Color(0xFFE0E0E0));
    }

    final normalized = (widget.sentiment!['normalized'] as num).toDouble();
    final String emoji;
    final String label;

    if (normalized > 0.3) {
      emoji = '😄';
      label = 'Positive';
    } else if (normalized < -0.3) {
      emoji = '😢';
      label = 'Negative';
    } else {
      emoji = '😐';
      label = 'Neutral';
    }

    return Chip(
        label: Text('$emoji $label'), backgroundColor: const Color(0xFFE0E0E0));
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
          style: TextStyle(
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
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13, 
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        visualDensity: VisualDensity.compact,
                      ),
                      _buildSentimentChip(),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 🖋️ Editable Title
                  isEditing
                      ? TextField(
                          controller: titleController,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter title...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            titleController.text.isNotEmpty
                                ? titleController.text
                                : 'Untitled entry',
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface, 
                              height: 1.25,
                            ),
                          ),
                        ),
                  const SizedBox(height: 8),

                  // ✍🏽 Editable Journal Body
                  isEditing
                      ? TextField(
                          controller: entryController,
                          style: TextStyle(fontSize: 15),
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write your thoughts...',
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            entryController.text,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                              height: 1.5,
                              letterSpacing: 0.1,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                  const SizedBox(height: 18),

                  // 🌸 Gentle Divider + Emotion Tag Area
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.favorite_border,
                          color: theme.colorScheme.secondary, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Take a deep breath — you’re doing great.',
                          style: const TextStyle(
                            color: Color(0xFF38B2AC),
                            fontSize: 12.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),

                  // AI Feedback Section
                  if (_loadingFeedback)
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (_aiFeedback != null && _aiFeedback!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _aiFeedback!,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF334155),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
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
          style: TextStyle(fontWeight: FontWeight.w500),
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
