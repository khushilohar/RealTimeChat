import 'package:get/get.dart';

class UserController extends GetxController {
  var currentUser = Rx<Map<String, dynamic>?>(null);
  var token = RxString('');

  void setUser(Map<String, dynamic> user, String jwtToken) {
    currentUser.value = user;
    token.value = jwtToken;
  }

  void clearUser() {
    currentUser.value = null;
    token.value = '';
  }
}