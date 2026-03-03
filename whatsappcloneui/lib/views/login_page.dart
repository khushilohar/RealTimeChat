import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart'; // 👈 import ApiService

class LoginPage extends StatelessWidget {
  LoginPage({super.key}); // 👈 change to LoginPage (not const) because we need a controller

  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.network(
                  'https://static.vecteezy.com/system/resources/previews/018/930/564/non_2x/whatsapp-logo-whatsapp-icon-whatsapp-transparent-free-png.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to WhatsApp',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: phoneController, // attach controller
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91 --- --- --- ---',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final phone = phoneController.text.trim();
                  if (phone.isEmpty) {
                    Get.snackbar('Error', 'Please enter phone number');
                    return;
                  }
                  // Call sendOtp
                  bool success = await ApiService.sendOtp(phone);
                  if (success) {
                    // Navigate to OTP page, passing phone number
                    Get.toNamed('/otp', arguments: phone);
                  } else {
                    Get.snackbar('Error', 'Failed to send OTP');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xff128C7E),
                  foregroundColor: Colors.white
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Realize our Privacy Policy. Tap Agree & Continue to accept the Terms of Service.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Home  FACEBOOK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}