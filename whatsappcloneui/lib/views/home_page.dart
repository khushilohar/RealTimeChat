import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart'; // 👈 import
import '../services/api_service.dart';
import '../controllers/user_controller.dart';
import 'chat_list.dart';
import 'status_list.dart';
import 'select_contact.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ChatController
    Get.put(ChatController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WhatsApp'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'logout') {
                  await ApiService.removeToken();
                  Get.find<UserController>().clearUser();
                  Get.offAllNamed('/');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
          backgroundColor: const Color(0xff128C7E),
          foregroundColor: const Color(0xffFFFFFF),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'CHATS'),
              Tab(text: 'STATUS'),
              Tab(text: 'CALLS'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChatsList(),
            StatusList(),
            Center(child: Text('Calls')), // placeholder
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (builder) => SelectContact()));
          },
          backgroundColor: const Color(0xff128C7E),
          foregroundColor: const Color(0xffFFFFFF),
          child: const Icon(Icons.message),
        ),
      ),
    );
  }
}