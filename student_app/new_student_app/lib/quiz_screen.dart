import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  bool _isAnalyzing = false;
  
  // Answers are scored: 0 (Not at all) to 3 (Nearly every day)
  final Map<String, int> _scores = {
    'Stress': 0,
    'Anxiety': 0,
    'Burnout': 0,
  };

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Over the last 2 weeks, how often have you felt nervous, anxious, or on edge?',
      'category': 'Anxiety',
    },
    {
      'question': 'How often have you felt overwhelmed by your academic or work load?',
      'category': 'Stress',
    },
    {
      'question': 'How often have you had trouble falling or staying asleep, or sleeping too much?',
      'category': 'Burnout',
    },
    {
      'question': 'How often have you felt so restless that it is hard to sit still?',
      'category': 'Anxiety',
    },
    {
      'question': 'How often have you felt little interest or pleasure in doing things?',
      'category': 'Burnout',
    },
  ];

  void _answerQuestion(int score) {
    final category = _questions[_currentQuestionIndex]['category'] as String;
    _scores[category] = (_scores[category] ?? 0) + score;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _analyzeResults();
    }
  }

  Future<void> _analyzeResults() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI Processing Delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Determine highest score category
    String recommendation = 'General';
    int maxScore = -1;
    
    _scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        recommendation = key;
      }
    });

    // If scores are very low, recommend general wellness
    if (maxScore <= 2) recommendation = 'Wellness';

    Navigator.pop(context, recommendation);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.indigo),
              const SizedBox(height: 20),
              Text(
                "MindCare AI is analyzing your responses...",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Finding the best resources for you.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Personalization Quiz", style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade100,
              color: Colors.indigo,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 40),
            Text(
              "Question ${_currentQuestionIndex + 1}/${_questions.length}",
              style: GoogleFonts.poppins(color: Colors.indigo, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
            ),
            const Spacer(),
            _buildOption(0, "Not at all"),
            _buildOption(1, "Several days"),
            _buildOption(2, "More than half the days"),
            _buildOption(3, "Nearly every day"),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int score, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: OutlinedButton(
        onPressed: () => _answerQuestion(score),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}