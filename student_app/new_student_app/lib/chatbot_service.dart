import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatbotService {
  // Use 10.0.2.2 for Android emulator to connect to host's localhost
  static final String _host = (kIsWeb || !Platform.isAndroid) ? 'localhost' : '10.0.2.2';
  static const String _port = '5000'; // 👈 Replace with your actual backend port
  static final String apiUrl = "http://$_host:$_port/ask";

  static Future<String> getResponse(String question) async {
    final response = await http.post(
      // Use Uri.http to handle encoding and components safely
      Uri.http('$_host:$_port', '/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"text": question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? "No response from chatbot.";
    } else {
      return "Failed to connect to chatbot: ${response.statusCode}";
    }
  }
}
