import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/bindings/active_orders_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/completed_orders_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/courier_assigned_orders_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/customer_shipments_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/home_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/login_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/order_search_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/user_search_binding.dart';
import 'package:ysy_kargo_panel/app/bindings/users_binding.dart';
import 'package:ysy_kargo_panel/app/ui/pages/home_page/home_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/login_page/login_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/active_orders_page/active_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/completed_orders_page/completed_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/courier_assigned_orders_page/courier_assigned_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/customer_shipments_page/customer_shipments_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/order_search_page/order_search_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/users_page/user_search_page/user_search_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/users_page/users_page.dart';

class RouteManager {
  static final RouteManager _instace = RouteManager._init();
  static RouteManager get instance {
    return _instace;
  }

  RouteManager._init();

  String get splashPage => '/splashPage';
  String get loginPage => '/loginPage';
  String get homePage => '/homePage';
  String get usersPage => '/usersPage';
  String get userSearchPage => '/userSearchPage';
  String get courierSearchPage => '/courierSearchPage';
  String get activeOrdersPage => '/activeOrdersPage';
  String get courierAssignedOrdersPage => '/courierAssignedOrdersPage';
  String get customerShipmentsPage => '/customerShipmentsPage';
  String get orderSearchPage => '/orderSearchPage';
  String get completedOrdersPage => '/completedOrdersPage';

  List<GetPage> get appPages => [
        GetPage(
          name: loginPage,
          page: () => const LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: homePage,
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: usersPage,
          page: () => const UsersPage(),
          binding: UsersBinding(),
        ),
        GetPage(
          name: userSearchPage,
          page: () => const UserSearchPage(initialSearchType: 'Müşteri'),
          binding: UserSearchBinding(),
        ),
        GetPage(
          name: courierSearchPage,
          page: () => const UserSearchPage(initialSearchType: 'Kurye'),
          binding: UserSearchBinding(),
        ),
        GetPage(
          name: activeOrdersPage,
          page: () => const ActiveOrdersPage(),
          binding: ActiveOrdersBinding(),
        ),
        GetPage(
          name: courierAssignedOrdersPage,
          page: () => const CourierAssignedOrdersPage(),
          binding: CourierAssignedOrdersBinding(),
        ),
        GetPage(
          name: customerShipmentsPage,
          page: () => const CustomerShipmentsPage(),
          binding: CustomerShipmentsBinding(),
        ),
        GetPage(
          name: orderSearchPage,
          page: () => const OrderSearchPage(),
          binding: OrderSearchBinding(),
        ),
        GetPage(
          name: completedOrdersPage,
          page: () => const CompletedOrdersPage(),
          binding: CompletedOrdersBinding(),
        ),
      ];
}
