import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/order_search_controller.dart';

class OrderSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderSearchController>(() => OrderSearchController());
  }
} 