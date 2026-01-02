import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/active_orders_controller.dart';

class ActiveOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActiveOrdersController>(() => ActiveOrdersController());
  }
}
