import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _storage = const FlutterSecureStorage(); // JWT Secure Storage

  bool otpSent = false;
  bool loading = false;

  /// 🔗 Replace with your local IP if testing on a real device
  final String baseUrl =
      "https://3261-2405-201-e03f-20bd-c9ed-956c-3ec6-baf.ngrok-free.app";

  Future<void> sendOtp() async {
    final contact = _contactController.text.trim();
    if (contact.isEmpty) {
      return showError("Please enter email or phone");
    }

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/send-otp"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"emailOrPhone": contact}),
      );

      if (res.statusCode == 200) {
        setState(() => otpSent = true);
        showSuccess("OTP sent to $contact");
      } else {
        final error = jsonDecode(res.body)['error'] ?? "Something went wrong";
        showError(error);
      }
    } catch (e) {
      showError("Network error. Please check your connection.");
    }

    setState(() => loading = false);
  }

  Future<void> verifyOtp() async {
    final contact = _contactController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      return showError("Enter a valid 6-digit OTP");
    }

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/verify-otp"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"emailOrPhone": contact, "otp": otp}),
      );

      if (res.statusCode == 200) {
        final token = jsonDecode(res.body)['token'];
        await _storage.write(key: "token", value: token);
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        final error = jsonDecode(res.body)['error'] ?? "Invalid OTP";
        showError(error);
      }
    } catch (e) {
      showError("Network error. Please try again.");
    }

    setState(() => loading = false);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ $message"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ $message"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "CareGoals ❤️",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  otpSent
                      ? "Enter the 6-digit OTP"
                      : "Enter your Email or Phone Number",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),
                if (!otpSent)
                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email or Phone",
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (otpSent)
                  PinCodeTextField(
                    appContext: context,
                    controller: _otpController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {},
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: loading ? null : (otpSent ? verifyOtp : sendOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(otpSent ? "Verify OTP" : "Send OTP"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
