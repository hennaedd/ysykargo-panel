import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/users_controller.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersController>(() => UsersController());
  }
}
