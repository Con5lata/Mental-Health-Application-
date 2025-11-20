import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TotpEnrollPage extends StatefulWidget {
  const TotpEnrollPage({super.key});

  @override
  State<TotpEnrollPage> createState() => _TotpEnrollPageState();
}

class _TotpEnrollPageState extends State<TotpEnrollPage> {
  String? qrUrl;
  dynamic secret;
  final _codeController = TextEditingController();
  bool verifying = false;

  @override
  void initState() {
    super.initState();
    generateTotpSecret();
  }

  Future<void> generateTotpSecret() async {
    final user = FirebaseAuth.instance.currentUser!;
    final multiFactor = user.multiFactor;

    final session = await multiFactor.getSession();

    final totpSecret = await TotpMultiFactorGenerator.generateSecret(session);

    setState(() {
      qrUrl = totpSecret.toString();
      secret = totpSecret;
    });
  }

  Future<void> verifyTotpCode() async {
    try {
      setState(() => verifying = true);

      final user = FirebaseAuth.instance.currentUser!;
      final multiFactor = user.multiFactor;

      final assertion = await secret.getAssertionForEnrollment(
        _codeController.text.trim(),
      );

      await multiFactor.enroll(assertion, displayName: "Authenticator App");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("MFA Enabled Successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid code: $e")));
    } finally {
      setState(() => verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enable MFA")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (qrUrl == null)
              Center(child: CircularProgressIndicator())
            else ...[
              Text("Scan this QR code in Google Authenticator:",
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              QrImageView(data: qrUrl!, size: 200),
              SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                    labelText: "Enter 6-digit code",
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifying ? null : verifyTotpCode,
                child: verifying
                    ? CircularProgressIndicator()
                    : Text("Verify & Enable MFA"),
              )
            ]
          ],
        ),
      ),
    );
  }
}
