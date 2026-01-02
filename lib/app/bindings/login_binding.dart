import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
