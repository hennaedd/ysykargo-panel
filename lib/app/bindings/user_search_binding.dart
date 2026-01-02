import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/user_search_controller.dart';

class UserSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserSearchController>(() => UserSearchController());
  }
}
