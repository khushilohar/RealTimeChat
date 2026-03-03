import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        backgroundColor: const Color(0xff128C7E),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['profile_pic'] != null
                      ? NetworkImage(user['profile_pic'])
                      : null,
                  child: user['profile_pic'] == null
                      ? Text(user['name']?[0].toUpperCase() ?? '?')
                      : null,
                ),
                title: Text(user['name'] ?? 'Unknown'),
                // Remove status or set a placeholder
                subtitle: const Text(''), // or Text(user['status'] ?? '') but backend has no status
                onTap: () {
                    Get.toNamed('/chat-detail', arguments: {
                      'userId': user['id'],
                      'name': user['name'] ?? 'Unknown',
                      'profileUrl': user['profile_pic'] ?? '',
                    });
                }
              );
            },
          );
        },
      ),
    );
  }
}