import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/customer_shipments_controller.dart';

class CustomerShipmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerShipmentsController>(() => CustomerShipmentsController());
  }
} 