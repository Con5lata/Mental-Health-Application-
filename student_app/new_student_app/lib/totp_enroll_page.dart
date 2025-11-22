import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'login_page.dart';

class TotpEnrollPage extends StatefulWidget {
  const TotpEnrollPage({super.key});

  @override
  State<TotpEnrollPage> createState() => _TotpEnrollPageState();
}

class _TotpEnrollPageState extends State<TotpEnrollPage> {
  final _codeController = TextEditingController();
  String? _factorId;
  String? _qrCodeUri;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startEnrollment();
  }

  // 1. Ask Supabase for a QR Code
  Future<void> _startEnrollment() async {
    try {
      final response = await Supabase.instance.client.auth.mfa.enroll(
        factorType: FactorType.totp,
      );
      
      setState(() {
        _factorId = response.id;
        _qrCodeUri = response.totp?.uri; // This URL generates the QR image
        _loading = false;
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 2. Verify the code user typed in
  Future<void> _verifyAndEnable() async {
    try {
      setState(() => _loading = true);
      
      await Supabase.instance.client.auth.mfa.challengeAndVerify(
        factorId: _factorId!,
        code: _codeController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("MFA Enabled!")));
        // Go to Login Page so they can test the flow
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid Code: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Your Account")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Scan this QR Code with Google Authenticator",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    // Display QR Code
                    if (_qrCodeUri != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: QrImageView(
                          data: _qrCodeUri!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    const Text("Enter the 6-digit code from the app:"),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        counterText: "",
                        hintText: "123456",
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _verifyAndEnable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Verify & Enable"),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}