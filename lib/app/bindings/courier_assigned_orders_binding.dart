import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/courier_assigned_orders_controller.dart';

class CourierAssignedOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourierAssignedOrdersController>(() => CourierAssignedOrdersController());
  }
} 