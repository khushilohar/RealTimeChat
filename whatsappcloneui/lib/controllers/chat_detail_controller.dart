import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/user_controller.dart';

class ChatDetailController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  final UserController userController = Get.find();
  late int contactId;
  late String contactName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    contactId = args['userId'];
    contactName = args['name'];
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final fetched = await ApiService.getConversation(contactId);
    messages.value = fetched;
  }

  void sendMessage(String text) async {
    // Optimistically add to UI
    messages.add({
      'text': text,
      'time': 'Just now',
      'isMe': true,
    });
    // Send to backend
    final success = await ApiService.sendMessage(contactId, text);
    if (!success) {
      Get.snackbar('Error', 'Message failed to send');
      // Optionally remove the optimistic message
    } else {
      // Optionally refresh messages to get real timestamp
      fetchMessages();
    }
  }
}