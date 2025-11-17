import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot_service.dart';

class AskAnonymousQuestionScreen extends StatefulWidget {
  const AskAnonymousQuestionScreen({super.key});

  @override
  State<AskAnonymousQuestionScreen> createState() => _AskAnonymousQuestionScreenState();
}

class _AskAnonymousQuestionScreenState extends State<AskAnonymousQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  bool _isSubmitting = false;
  String _aiResponse = '';
  bool _hasTyped = false;

  Future<void> _submitQuestion() async {
    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) return;
  
    setState(() {
      _isSubmitting = true;
      _aiResponse = '';
    });
  
    try {
      // 🔹 Get AI response from backend
      final aiResponse = await ChatbotService.getResponse(questionText);
  
      // 🔹 Save to Firestore
      await FirebaseFirestore.instance.collection('qna').add({
        'question': questionText,
        'author_id': 'anonymous',
        'created_at': Timestamp.now(),
        'status': 'answered',
        'response': aiResponse,
      });
  
      // 🔹 Update UI
      if (mounted) {
        setState(() {
          _aiResponse = aiResponse;
          _questionController.clear();
          _hasTyped = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasTyped && _questionController.text.isNotEmpty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Discard Question?'),
          content: const Text('You have unsent text. Do you want to discard it?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Discard')),
          ],
        ),
      );
      return discard ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ask an Anonymous Question',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your identity will remain anonymous.\nAsk about mental health, study stress, or general wellness — our team is here to help.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Question',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _questionController,
                  maxLines: 6,
                  onChanged: (_) => setState(() => _hasTyped = true),
                  decoration: InputDecoration(
                    hintText: 'Type your question here...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit Question',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (_aiResponse.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our AI Assistant Says:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _aiResponse,
                        style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
