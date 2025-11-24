import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // ⚠️ REPLACE WITH YOUR API KEY from https://aistudio.google.com/
  static const String _apiKey = "AIzaSyAT8SDB02Efx2JfNr-eTZBnxx3oRCEXMNQ"; 

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<Map<String, dynamic>> analyzeJournal(String text) async {
    if (text.length < 10) {
      // Too short to analyze
      return {
        'score': 0.0,
        'tags': ['Neutral'],
        'feedback': 'Keep writing to get more insights!',
      };
    }

    final prompt = '''
      You are an empathetic mental health assistant. Analyze the following journal entry:
      "$text"

      Return ONLY a valid JSON object (no markdown, no code blocks) with these 3 fields:
      1. "score": A float between -1.0 (very negative) and 1.0 (very positive).
      2. "tags": A list of 3 short strings representing the key emotions or topics (e.g., "Anxiety", "School", "Hope").
      3. "feedback": A 1-2 sentence supportive, empathetic, and non-judgmental reflection on what was written.

      Example format:
      {"score": -0.5, "tags": ["Stress", "Exams"], "feedback": "It sounds like you are under a lot of pressure right now. Remember to take breaks."}
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      String? responseText = response.text;
      
      if (responseText == null) throw "Empty response";

      // Clean up markdown if Gemini adds it (sometimes it adds ```json ... ```)
      responseText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      return jsonDecode(responseText);
    } catch (e) {
      print("AI Error: $e");
      // Fallback if AI fails or no internet
      return {
        'score': 0.0,
        'tags': ['Journal'],
        'feedback': 'Analysis unavailable at the moment.',
      };
    }
  }
}