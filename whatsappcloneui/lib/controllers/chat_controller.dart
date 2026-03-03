import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/user_controller.dart';

class ChatController extends GetxController {
  var chats = <Map<String, dynamic>>[].obs;
  final UserController userController = Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final users = await ApiService.fetchUsers();
    final currentUserId = userController.currentUser.value?['id'];
    // Filter out current user and map to chat preview format
    final chatList = users.where((u) => u['id'] != currentUserId).map((u) {
      return {
        'name': u['name'] ?? 'Unknown',
        'message': 'Tap to chat', // placeholder; you can add last message later
        'time': '',
        'profileUrl': u['profile_pic'] ?? '',
        'userId': u['id'], // store for navigation
      };
    }).toList();
    chats.value = chatList;
  }

  void goToChatDetail(Map<String, dynamic> contact) {
    Get.toNamed('/chat-detail', arguments: contact);
  }
}