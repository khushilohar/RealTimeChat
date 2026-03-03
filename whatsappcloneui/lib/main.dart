import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/user_controller.dart'; // <-- import
import 'views/splash_screen.dart';
import 'views/login_page.dart';
import 'views/otp_page.dart';
import 'views/home_page.dart';
import 'views/chat_detail_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp Clone',
      theme: ThemeData(),
      initialBinding: BindingsBuilder(() {
        Get.put(UserController()); // <-- register here
      }),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/', page: () =>  LoginPage()),
        GetPage(name: '/otp', page: () => const OtpPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/chat-detail', page: () => const ChatDetailScreen()),
      ],
    );
  }
}