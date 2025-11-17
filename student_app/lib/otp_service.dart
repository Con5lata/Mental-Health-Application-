import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class OtpService {
  final String serviceId = 'YOUR_SERVICE_ID';
  final String templateId = 'YOUR_TEMPLATE_ID';
  final String userId = 'YOUR_PUBLIC_KEY';

  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<bool> sendOtpEmail(String email, String otp) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': email,
          'otp': otp,
        },
      }),
    );

    return response.statusCode == 200;
  }
}
