import 'package:flexus_ext/app/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../controllers/version_controller.dart';
import 'auth.dart';

class Bindings {
  void dependencies() {
    Get.put(VersionController());
    Get.put(AuthController());
    Get.put(Auth());
  }
}
