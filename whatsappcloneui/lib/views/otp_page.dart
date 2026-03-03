import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart'; 

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final TextEditingController otpController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final String phoneNumber = Get.arguments as String? ?? '';
    if (phoneNumber.isEmpty) {
      // fallback – maybe redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamed('/');
      });
  return const Scaffold(body: Center(child: Text('Invalid navigation')));
}
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        backgroundColor: const Color(0xff128C7E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Icon(
                Icons.sms,
                size: 80,
                color: Color(0xff128C7E),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter the 6-digit code',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'We have sent a verification code to\n$phoneNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  label: Text("Name"),
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                ),
                
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: const TextStyle(letterSpacing: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final otp = otpController.text.trim();
                  final name = nameController.text.trim();
                  if (otp.length != 6) {
                    Get.snackbar('Error', 'Enter 6-digit OTP');
                    return;
                  }
                  // Call verifyOtp
                  final user = await ApiService.verifyOtp(phoneNumber, otp, name);
                  if (user != null) {
                    // Success – go to home
                    Get.offAllNamed('/home');
                  } else {
                    Get.snackbar('Error', 'Invalid OTP');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xff128C7E),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  // Resend OTP
                  bool success = await ApiService.sendOtp(phoneNumber);
                  if (success) {
                    Get.snackbar('Success', 'OTP resent');
                  } else {
                    Get.snackbar('Error', 'Failed to resend OTP');
                  }
                },
                child: const Text(
                  'Resend code',
                  style: TextStyle(color: Color(0xff128C7E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}