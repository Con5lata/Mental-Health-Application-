import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatbotService {
  // ✅ Configure base URL depending on platform.
  // - Android emulator: use 10.0.2.2 -> host machine
  // - iOS simulator / web / desktop: use localhost
  //
  // NOTE: If you run on a *real device*, change this to your PC's LAN IP,
  // e.g. '192.168.1.50:5000'.
  static final String _baseHostPort = () {
    if (kIsWeb) return 'localhost:5000';
    if (Platform.isAndroid) {
      // Android emulator
      return '10.55.35.82';
    }
    // iOS simulator / desktop
    return 'localhost:5000';
  }();

  // Final ASK endpoint
  static final Uri _askUri = Uri.parse('http://$_baseHostPort/ask');

  static Future<String> getResponse(String question) async {
    try {
      final response = await http
          .post(
            _askUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"text": question}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response']?.toString() ?? "No response from chatbot.";
      } else {
        return "Failed to connect to chatbot: HTTP ${response.statusCode}";
      }
    } catch (e) {
      // This is where SocketException / timeout / no route to host will end up
      return "Unable to reach chatbot service. Please ensure the backend is running at $_askUri. Details: $e";
    }
  }
}
