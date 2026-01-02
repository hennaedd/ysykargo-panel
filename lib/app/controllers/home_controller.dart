import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/model/categories_model.dart';
import 'package:ysy_kargo_panel/app/routes/route_manager.dart';
import 'package:ysy_kargo_panel/app/ui/pages/notifications_page/notifications_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/active_orders_page/active_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/completed_orders_page/completed_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/courier_assigned_orders_page/courier_assigned_orders_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/customer_shipments_page/customer_shipments_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/orders_page/order_search_page/order_search_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/pending_couriers_page/pending_couriers_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/users_page/user_search_page/user_search_page.dart';
import 'package:ysy_kargo_panel/app/ui/pages/users_page/users_page.dart';

class HomeController extends GetxController {
  String adminName = 'Yönetici';
  String adminEmail = 'admin@admin.com';
  String adminPassword = '123456';

  int selectedIndex = 0;
  bool showProfile = false;
  String selectedSubcategory = '';
  Widget? currentPageWidget;

  // Counts for dashboard stats
  int totalShipments = 0;
  int activeCouriers = 0;
  int completedShipments = 0;
  int activeShipments = 0;
  int pendingCouriers = 0;
  int bannedUsers = 0;

  final List<CategoriesModel> menuCategories = [
    CategoriesModel(kategori: ['Anasayfa'], subKategori: []),
    CategoriesModel(
      kategori: ['Kullanıcı İşlemleri'],
      subKategori: [
        'Kullanıcıları Listele',
        'Onay Bekleyen Kuryeler',
        'Müşteri Ara',
        'Kurye Ara',
      ],
    ),
    CategoriesModel(
      kategori: ['Sipariş İşlemleri'],
      subKategori: [
        'Aktif Siparişler',
        'Kuryeye Atanmış Siparişler',
        'Tamamlanan Siparişler',
        'Müşteriye Ait Gönderiler',
        'Sipariş Numarasına Göre Ara',
      ],
    ),
    CategoriesModel(
      kategori: ['Bildirimler'],
      subKategori: ['Bildirim Gönder'],
    ),
  ];

  // Firebase Realtime Database references
  final DatabaseReference _shipmentsRef = FirebaseDatabase.instance.ref().child(
        'gönderiler',
      );
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child(
        'users',
      );

  @override
  void onInit() {
    super.onInit();
    loadAdminDataFromFirebase();
    fetchDashboardStats();
  }

  Future<void> loadAdminDataFromFirebase() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('admin')
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        adminName = data['name_surname'] ?? 'Yönetici';
        adminEmail = data['email'] ?? 'admin@admin.com';
        adminPassword = data['password'] ?? '123456';
        update();
      }
    } catch (e) {
      print('Firebase veri çekme hatası: $e');
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      // Fetch total shipments, pending shipments, and active shipments
      final shipmentsSnapshot = await _shipmentsRef.get();
      totalShipments = 0;
      activeShipments = 0;
      completedShipments = 0;

      if (shipmentsSnapshot.exists) {
        final shipmentsData = shipmentsSnapshot.value as Map?;
        if (shipmentsData != null) {
          // Iterate through each UID
          shipmentsData.forEach((uid, shipments) {
            if (shipments is Map) {
              // Count shipments under this UID
              totalShipments += shipments.length;

              // Check each shipment for package_status
              shipments.forEach((shipmentId, shipmentDetails) {
                if (shipmentDetails is Map) {
                  final packageStatus =
                      shipmentDetails['packageStatus'] as String?;
                  if (packageStatus == 'Aktif') {
                    activeShipments++;
                  }
                  if (packageStatus == 'Gönderi Teslim Edildi') {
                    completedShipments++;
                  }
                }
              });
            }
          });
        }
      }

      // Fetch user statistics
      final usersSnapshot = await _usersRef.get();
      activeCouriers = 0;
      pendingCouriers = 0;
      bannedUsers = 0;

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map?;
        if (usersData != null) {
          usersData.forEach((key, value) {
            if (value is Map) {
              final userType = value['user_type'] as String?;
              final accountStatus = value['account_status'] as String?;

              // Count active approved couriers
              if (userType == 'Kurye' && accountStatus == 'approved') {
                activeCouriers++;
              }

              // Count pending couriers
              if (userType == 'Kurye' && accountStatus == 'pending') {
                pendingCouriers++;
              }

              // Count banned users (any type)
              if (accountStatus == 'banned') {
                bannedUsers++;
              }
            }
          });
        }
      }

      update(); // Update the UI with the new counts
    } catch (e) {
      print('Dashboard istatistikleri yüklenirken hata oluştu: $e');
    }
  }

  Future<void> updateAdminProfile({String? name, String? password}) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null && name.isNotEmpty) {
        updateData['name_surname'] = name;
        adminName = name;
      }
      if (password != null && password.isNotEmpty) {
        updateData['password'] = password;
        adminPassword = password;
      }
      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('admin')
            .doc('admin')
            .update(updateData);
        Get.snackbar(
          'Başarılı',
          'Profil bilgileriniz güncellendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        update();
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Profil güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print('Firebase güncelleme hatası: $e');
    }
  }

  void changeSelectedIndex(int index) {
    selectedIndex = index;
    if (menuCategories[index].subKategori.isEmpty) {
      selectedSubcategory = '';
      currentPageWidget = null; // Ana sayfaya dönüldüğünde widget'i temizle
    }
    showProfile = false;
    update();
  }

  void selectSubcategory(String subcategory) {
    selectedSubcategory = subcategory;

    // Alt kategori seçildiğinde doğru sayfaya yönlendir
    if (subcategory.isNotEmpty) {
      _loadPageForSubcategory(subcategory);
    } else {
      currentPageWidget =
          null; // Alt kategori temizlendiğinde widget'i de temizle
    }

    update();
  }

  void _loadPageForSubcategory(String subcategory) {
    switch (subcategory) {
      case 'Kullanıcıları Listele':
        currentPageWidget = const UsersPage();
        break;
      case 'Onay Bekleyen Kuryeler':
        currentPageWidget = const PendingCouriersPage();
        break;
      case 'Müşteri Ara':
        currentPageWidget = const UserSearchPage(initialSearchType: 'Müşteri');
        break;
      case 'Kurye Ara':
        currentPageWidget = const UserSearchPage(initialSearchType: 'Kurye');
        break;
      case 'Aktif Siparişler':
        currentPageWidget = const ActiveOrdersPage();
        break;
      case 'Tamamlanan Siparişler':
        currentPageWidget = const CompletedOrdersPage();
        break;
      case 'Kuryeye Atanmış Siparişler':
        currentPageWidget = const CourierAssignedOrdersPage();
        break;
      case 'Müşteriye Ait Gönderiler':
        currentPageWidget = const CustomerShipmentsPage();
        break;
      case 'Sipariş Numarasına Göre Ara':
        currentPageWidget = const OrderSearchPage();
        break;
      case 'Bildirim Gönder':
        currentPageWidget = const NotificationsPage();
        break;
      default:
        currentPageWidget = null;
    }
  }

  void toggleProfileView() {
    showProfile = !showProfile;
    if (showProfile) {
      selectedIndex = -1;
      selectedSubcategory = '';
    } else {
      selectedIndex = 0;
      selectedSubcategory = '';
    }
    update();
  }

  void logout() {
    Get.offAllNamed(RouteManager.instance.loginPage);
  }
}
