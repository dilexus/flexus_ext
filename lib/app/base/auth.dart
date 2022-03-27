import 'package:get/get.dart';

import '../data/models/auth_user_model.dart';

class Auth {
  static Auth get instance => Get.find();
  AuthUser? authUser;
}
