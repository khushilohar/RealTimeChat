import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed('/'); 
    });

    return Scaffold(
      body: Container(
        color: const Color(0xffFFFFFF), // WhatsApp green background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
  
              Image.network(
                'https://static.vecteezy.com/system/resources/previews/018/930/564/non_2x/whatsapp-logo-whatsapp-icon-whatsapp-transparent-free-png.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 10),
              const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}