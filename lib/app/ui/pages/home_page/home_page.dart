import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ysy_kargo_panel/app/controllers/home_controller.dart';
import 'package:ysy_kargo_panel/app/model/categories_model.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/active_orders_page/active_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/completed_orders_page/completed_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/courier_assigned_orders_page/courier_assigned_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/customer_shipments_page/customer_shipments_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/order_search_page/order_search_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/users_page/user_search_page/user_search_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/users_page/users_page.dart';
import 'package:ysy_kargo_panel/app/ui/widgets/sidebar_widget.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      final isWideScreen = MediaQuery.of(context).size.width >= 900;

      return Scaffold(
        backgroundColor: ColorManager.instance.white,
        appBar: AppBar(
          surfaceTintColor: ColorManager.instance.transparent,
          backgroundColor: ColorManager.instance.white,
          elevation: 0,
          centerTitle: false,
          leading: isWideScreen
              ? null
              : Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: ColorManager.instance.orange),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
          title: SelectableText(
            'YSY Kargo Yönetici Paneli',
            style: TextStyle(
              color: ColorManager.instance.black,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          actions: [
            InkWell(
              onTap: controller.toggleProfileView,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  backgroundColor:
                      ColorManager.instance.orange.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: controller.showProfile
                        ? ColorManager.instance.orange
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: isWideScreen
            ? null
            : const Drawer(
                child: SidebarWidget(),
              ),
        body: Row(
          children: [
            if (isWideScreen) const SidebarWidget(),
            Expanded(
              child: Container(
                color: ColorManager.instance.softGrayBg,
                padding: EdgeInsets.all(isWideScreen ? 24 : 16),
                child: controller.showProfile
                    ? _buildProfileView(controller)
                    : _buildMainContent(controller),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProfileView(HomeController controller) {
    final nameController = TextEditingController(text: controller.adminName);
    final passwordController =
        TextEditingController(text: controller.adminPassword);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          'Profil Bilgileri',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: ColorManager.instance.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorManager.instance.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          ColorManager.instance.orange.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: ColorManager.instance.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SelectableText(
                      'Yönetici Hesabı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const SelectableText(
                'İsim Soyisim',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'İsim Soyisim giriniz',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const SelectableText(
                'E-posta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: controller.adminEmail),
                decoration: const InputDecoration(
                  hintText: 'E-posta adresi',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 24),
              const SelectableText(
                'Şifre',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'Şifre giriniz',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: KargoButton(
                  text: 'Profili Güncelle',
                  textStyle: const TextStyle(fontSize: 12),
                  buttonColor: ColorManager.instance.orange,
                  width: 200,
                  onTap: () async {
                    await controller.updateAdminProfile(
                      name: nameController.text,
                      password: passwordController.text,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          'Hoş Geldin, ${controller.adminName}',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: ColorManager.instance.black,
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          'Panel üzerinden tüm işlemleri yönetebilirsin.',
          style: TextStyle(
            fontSize: 16,
            color: ColorManager.instance.darkGray,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(child: _buildContentArea(controller)),
      ],
    );
  }

  Widget _buildContentArea(HomeController controller) {
    if (controller.currentPageWidget != null) {
      return controller.currentPageWidget!;
    }

    final selectedIndex = controller.selectedIndex;
    if (selectedIndex < 0 ||
        selectedIndex >= controller.menuCategories.length) {
      return const SizedBox.shrink();
    }

    final category = controller.menuCategories[selectedIndex];
    final subCategory = controller.selectedSubcategory;

    if (selectedIndex == 0) {
      return _buildDashboard(controller);
    } else if (subCategory.isNotEmpty) {
      return _buildSubcategoryContent(subCategory, controller);
    } else {
      return _buildCategoryContent(category, controller);
    }
  }

  Widget _buildSubcategoryContent(
      String subCategory, HomeController controller) {
    return Center(
      child: SelectableText(
        'Sayfa yüklenemedi',
        style: TextStyle(
          fontSize: 16,
          color: ColorManager.instance.darkGray,
        ),
      ),
    );
  }

  Widget _buildDashboard(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SelectableText(
          'Genel Bakış',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // First row - Shipment stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: _buildStatCard(
                    'Toplam Sipariş',
                    controller.totalShipments.toString(),
                    Icons.shopping_bag,
                    ColorManager.instance.orange)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard(
                    'Tamamlanan Siparişler',
                    controller.completedShipments.toString(),
                    Icons.delivery_dining,
                    Colors.green)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard(
                    'Aktif Siparişler',
                    controller.activeShipments.toString(),
                    Icons.hourglass_empty,
                    Colors.amber)),
          ],
        ),
        const SizedBox(height: 16),
        // Second row - User stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: _buildStatCard(
                    'Aktif Kuryeler',
                    controller.activeCouriers.toString(),
                    Icons.motorcycle,
                    Colors.blue)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard(
                    'Onay Bekleyen Kuryeler',
                    controller.pendingCouriers.toString(),
                    Icons.pending_actions,
                    Colors.orange)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard(
                    'Banlı Kullanıcılar',
                    controller.bannedUsers.toString(),
                    Icons.block,
                    Colors.red)),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 120,
      decoration: BoxDecoration(
        color: ColorManager.instance.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 14, color: ColorManager.instance.darkGray),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorManager.instance.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(
      CategoriesModel category, HomeController controller) {
    final selectedSubcategory = controller.selectedSubcategory;
    final mainCategory = category.kategori[0];

    final Map<String, Widget> subcategoryWidgets = {
      'Kullanıcıları Listele': const UsersPage(),
      'Müşteri Ara': const UserSearchPage(initialSearchType: "Müşteri"),
      'Kurye Ara': const UserSearchPage(initialSearchType: "Kurye"),
      'Aktif Siparişler': const ActiveOrdersPage(),
      'Kuryeye Atanmış Siparişler': const CourierAssignedOrdersPage(),
      'Tamamlanan Siparişler': const CompletedOrdersPage(),
      'Müşteriye Ait Gönderiler': const CustomerShipmentsPage(),
      'Sipariş Numarasına Göre Ara': const OrderSearchPage()
      // Add other subcategory widgets as needed
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            mainCategory,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (selectedSubcategory.isNotEmpty)
            SelectableText(
              '> $selectedSubcategory',
              style:
                  TextStyle(fontSize: 16, color: ColorManager.instance.orange),
            ),
          const SizedBox(height: 24),
          selectedSubcategory.isNotEmpty &&
                  subcategoryWidgets.containsKey(selectedSubcategory)
              ? subcategoryWidgets[selectedSubcategory]!
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ColorManager.instance.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        selectedSubcategory.isEmpty
                            ? '$mainCategory İçeriği'
                            : '$selectedSubcategory İçeriği',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        selectedSubcategory.isEmpty
                            ? 'Bu bölümde $mainCategory ile ilgili işlemler yapabilirsiniz.'
                            : 'Bu bölümde $selectedSubcategory ile ilgili işlemler yapabilirsiniz.',
                        style: TextStyle(
                            fontSize: 16,
                            color: ColorManager.instance.darkGray),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
