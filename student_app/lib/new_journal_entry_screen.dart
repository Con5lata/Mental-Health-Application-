import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class NewJournalEntryScreen extends StatefulWidget {
  const NewJournalEntryScreen({super.key});

  @override
  State<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _NewJournalEntryScreenState extends State<NewJournalEntryScreen> {
  final TextEditingController _entryController = TextEditingController();
  final List<String> _tags = ['Stress', 'Study', 'Reflection'];
  final List<String> _selectedTags = [];
  bool _isSaving = false;

  final String defaultUserId = '61xtbNAWg1gYxOH9lMCZ8u2Sxq23'; // mock user

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
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
    final entryText = _entryController.text.trim();
    if (entryText.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('journals').add({
        'entry': entryText,
        'tags': _selectedTags,
        'created_at': Timestamp.now(),
        'user_id': defaultUserId, // ✅ link to user
      });

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _deleteEntry() {
    Navigator.of(context).pop();
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(hintText: 'Tag name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addTag(tagController.text.trim());
              Navigator.of(context).pop();
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'New Entry',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: TextField(
                controller: _entryController,
                maxLines: 8,
                style: GoogleFonts.poppins(fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Type your reflection or journal note here...',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add Tags',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ..._tags.map((tag) => ChoiceChip(
                      label: Text(tag, style: GoogleFonts.poppins()),
                      selected: _selectedTags.contains(tag),
                      shape: const StadiumBorder(),
                      selectedColor:
                          theme.colorScheme.primary.withOpacity(0.2),
                      backgroundColor: Colors.grey[200],
                      onSelected: (_) => _toggleTag(tag),
                    )),
                ActionChip(
                  label: const Icon(Icons.add),
                  onPressed: _showAddTagDialog,
                  backgroundColor:
                      theme.colorScheme.secondary.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Save Entry',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _deleteEntry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black12),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Journal Entry Editor',
                style: GoogleFonts.poppins(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
