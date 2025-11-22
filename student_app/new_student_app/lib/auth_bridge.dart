import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AuthBridge {
  // ---------------------------------------------------------------------------
  // YOUR CORRECT IP ADDRESS FOUND FROM 'ipconfig':
  // Wireless LAN adapter Wi-Fi: 10.55.41.186
  // ---------------------------------------------------------------------------
  static const String bridgeUrl = 'http://10.55.41.186:3000/bridge-auth'; 

  static Future<void> swapSupabaseForFirebase(String supabaseUserId, String email) async {
    print("🔄 Connecting to Bridge at: $bridgeUrl");

    try {
      final response = await http.post(
        Uri.parse(bridgeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'supabaseUserId': supabaseUserId,
          'email': email,
        }),
      ).timeout(const Duration(seconds: 5)); // Fail fast if no connection

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String firebaseCustomToken = data['firebaseToken'];
        
        print("🔑 Token received. Signing into Firebase...");
        await FirebaseAuth.instance.signInWithCustomToken(firebaseCustomToken);
        print("✅ SUCCESS: Firebase Connected!");
      } else {
        throw "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      print("❌ CONNECTION ERROR: $e");
      // RETHROW a friendly error for the UI
      throw "Cannot reach Computer ($bridgeUrl). \n\nPossible Fixes:\n1. Ensure Node.js server is running.\n2. Since you are on 'strathmore.local', the school Wi-Fi might block device-to-device connections.\n   -> TRY USING A MOBILE HOTSPOT instead if this fails.";
    }
  }
}