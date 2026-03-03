import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();

    return Obx(() => ListView.builder(
          itemCount: controller.chats.length,
          itemBuilder: (context, index) {
            final chat = controller.chats[index];
            return ListTile(
              onTap: () => controller.goToChatDetail(chat),
              leading: CircleAvatar(
                backgroundImage: chat['profileUrl'] != null && chat['profileUrl'].isNotEmpty
                    ? NetworkImage(chat['profileUrl'])
                    : null,
                backgroundColor: Colors.green[100],
                child: (chat['profileUrl'] == null || chat['profileUrl'].isEmpty)
                    ? Text(chat['name'][0].toUpperCase())
                    : null,
              ),
              title: Text(chat['name']),
              subtitle: Text(chat['message']),
              trailing: Text(chat['time']),
            );
          },
        ));
  }
}