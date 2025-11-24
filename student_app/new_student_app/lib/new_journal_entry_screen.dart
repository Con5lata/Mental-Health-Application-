import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewJournalEntryScreen extends StatefulWidget {
  const NewJournalEntryScreen({super.key});

  @override
  State<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _NewJournalEntryScreenState extends State<NewJournalEntryScreen> {
  final _titleController = TextEditingController();
  final _entryController = TextEditingController();
  final List<String> _tags = ['Stress', 'Study', 'Reflection', 'Anxiety', 'Gratitude'];
  final List<String> _selectedTags = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _entryController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  
  void _toggleTag(String tag) {
    setState(() {
      _selectedTags.contains(tag)
          ? _selectedTags.remove(tag)
          : _selectedTags.add(tag);
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _selectedTags.add(tag);
      });
    }
  }

  Future<void> _saveEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save an entry.')),
      );
      return;
    }

    if (_titleController.text.isEmpty || _entryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Save to Firestore IMMEDIATELY
      // We send the manual tags selected by the user.
      // We set 'sentiment' to null to trigger the Python Colab script.
      await FirebaseFirestore.instance.collection('journals').add({
        'user_id': user.uid,
        'title': _titleController.text.trim(),
        'entry': _entryController.text.trim(),
        'manual_tags': _selectedTags, // Save user-selected tags separate from AI tags
        'created_at': FieldValue.serverTimestamp(),
        
        // CRITICAL: Setting this to null triggers the Python script listener
        'sentiment': null, 
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Journal saved! AI analysis will happen in the background."),
            backgroundColor: Colors.indigo,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Tag', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
            hintText: 'Enter new tag...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addTag(tagController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'New Journal Entry',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                : Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
              onPressed: _isSaving ? null : _saveEntry,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ Title Field
            Text(
              "Title",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'e.g., A challenging day',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✨ Entry Field
            Text(
              "How are you feeling today?",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _entryController,
                maxLines: 10,
                style: GoogleFonts.poppins(fontSize: 15, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Write your thoughts, feelings, or reflections...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  contentPadding: const EdgeInsets.all(18),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🌸 Tags Section
            Text(
              'Tags (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._tags.map(
                  (tag) => ChoiceChip(
                    label: Text(
                      tag,
                      style: GoogleFonts.poppins(
                        color: _selectedTags.contains(tag)
                            ? theme.colorScheme.primary
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedTags.contains(tag),
                    selectedColor:
                        theme.colorScheme.primary.withOpacity(0.1),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => _toggleTag(tag),
                  ),
                ),
                ActionChip(
                  label: const Icon(Icons.add, size: 18),
                  onPressed: _showAddTagDialog,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 💾 Save Button (Bottom)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Save Entry',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text("Syncing with AI...", style: GoogleFonts.poppins(color: Colors.grey)),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // 🗑 Delete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.delete_outline, color: Colors.black54),
                label: Text(
                  'Discard',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}