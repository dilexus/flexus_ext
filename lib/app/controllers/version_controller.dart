import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionController extends GetxController {
  static VersionController get instance => Get.find();
  final version = ''.obs;

  @override
  Future<void> onInit() async {
    var packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    super.onInit();
  }
}
