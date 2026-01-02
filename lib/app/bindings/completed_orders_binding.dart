import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/completed_orders_controller.dart';

class CompletedOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompletedOrdersController>(() => CompletedOrdersController());
  }
}
