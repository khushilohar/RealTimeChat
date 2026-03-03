import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/chat_detail_controller.dart';
import 'chat_bubble.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  Future<void> _takePhoto(ChatDetailController controller) async {
    final picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        // For now just add a text placeholder – you can extend later
        controller.sendMessage('📷 Photo taken');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open camera: $e');
    }
  }

  Future<void> _pickImageFromGallery(ChatDetailController controller) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        controller.sendMessage('📷 Image selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> contact = Get.arguments as Map<String, dynamic>;
    final String contactName = contact['name'];
    final ChatDetailController controller = Get.put(ChatDetailController());
    final TextEditingController messageController = TextEditingController();

    Widget _buildBottomSheet() {
      return Container(
        height: 278,
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.all(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      Icons.insert_drive_file,
                      Colors.indigo,
                      "Document",
                      () => Get.back(),
                    ),
                    const SizedBox(width: 40),
                    _buildIconButton(
                      Icons.camera_alt,
                      Colors.pink,
                      "Camera",
                      () {
                        Get.back();
                        _takePhoto(controller);
                      },
                    ),
                    const SizedBox(width: 40),
                    _buildIconButton(
                      Icons.insert_photo,
                      Colors.purple,
                      "Gallery",
                      () {
                        Get.back();
                        _pickImageFromGallery(controller);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      Icons.headphones,
                      Colors.orange,
                      "Audio",
                      () => Get.back(),
                    ),
                    const SizedBox(width: 40),
                    _buildIconButton(
                      Icons.location_on,
                      Colors.green,
                      "Location",
                      () => Get.back(),
                    ),
                    const SizedBox(width: 40),
                    _buildIconButton(
                      Icons.person,
                      Colors.blue,
                      "Contact",
                      () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );


      
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contactName),
            const Text(
              'online',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
        backgroundColor: const Color(0xff128C7E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    return ChatBubble(
                      message: msg['text'],
                      time: msg['time'],
                      isMe: msg['isMe'],
                    );
                  },
                )),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.sendMessage(value);
                        messageController.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.emoji_emotions_outlined),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (builder) => _buildBottomSheet(),
                              );
                            },
                            icon: const Icon(Icons.attach_file),
                          ),
                          IconButton(
                            onPressed: () => _takePhoto(controller),
                            icon: const Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xff25D366),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () {
                      final text = messageController.text.trim();
                      if (text.isNotEmpty) {
                        controller.sendMessage(text);
                        messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 29),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}