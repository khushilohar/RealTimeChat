import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator

  // Store token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Send OTP
  static Future<bool> sendOtp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/sendOtp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('sendOtp error: $e');
      return false;
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>?> verifyOtp(
    String phoneNumber,
    String otp, 
    String name,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verifyOtp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'otp': otp,
        'name': name,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      // Store user in GetX controller
      final userController = Get.find<UserController>();
      userController.setUser(data['user'], data['token']);
      return data['user'];
    }
    return null;
  }

  // Fetch all users (requires token)
  static Future<List<dynamic>> fetchUsers() async {
    final token = await getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Get conversation with a specific contact
  static Future<List<Map<String, dynamic>>> getConversation(int contactId) async {
    final token = await getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/message/conversation/$contactId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final currentUserId = Get.find<UserController>().currentUser.value?['id'];
      return data.map((msg) {
        return {
          'text': msg['message'],
          'time': _formatTime(msg['created_at']),
          'isMe': msg['sender_id'] == currentUserId,
        };
      }).toList();
    }
    return [];
  }

  // Send a message via HTTP (fallback)
  static Future<bool> sendMessage(int receiverId, String message) async {
    final token = await getToken();
    if (token == null) return false;
    final response = await http.post(
      Uri.parse('$baseUrl/message'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiverId': receiverId,
        'message': message,
        'messageType': 'text',
      }),
    );
    return response.statusCode == 201;
  }

  static String _formatTime(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.hour}:${date.minute}';
  }
}