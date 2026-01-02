import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActiveOrdersController extends GetxController {
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = false;
  String searchText = '';
  late TextEditingController
      searchController; // Persist the TextEditingController

  final DatabaseReference _shipmentsRef =
      FirebaseDatabase.instance.ref().child('gönderiler');

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController(); // Initialize the controller
    loadActiveOrders();
  }

  @override
  void onClose() {
    searchController
        .dispose(); // Dispose of the controller when the controller is closed
    super.onClose();
  }

  Future<void> loadActiveOrders() async {
    isLoading = true;
    update();

    try {
      allOrders.clear();
      filteredOrders.clear();

      final DataSnapshot snapshot = await _shipmentsRef.get();
      if (snapshot.exists) {
        final shipmentsData = snapshot.value as Map?;
        if (shipmentsData != null) {
          shipmentsData.forEach((userId, shipments) {
            if (shipments is Map) {
              shipments.forEach((orderId, shipmentDetails) {
                if (shipmentDetails is Map) {
                  final packageStatus =
                      shipmentDetails['packageStatus'] as String?;
                  if (packageStatus == 'Aktif') {
                    final order = Map<String, dynamic>.from(shipmentDetails);
                    order['userId'] = userId;
                    order['orderId'] = orderId;
                    order['content'] = shipmentDetails['content'] ?? '-';
                    order['packageStatus'] = packageStatus;
                    order['aliciIsimSoyisim'] =
                        shipmentDetails['aliciIsimSoyisim'] ?? '-';
                    order['aliciPhone'] = shipmentDetails['phone'] ?? '-';
                    order['aliciAdres'] = shipmentDetails['aliciAdres'] ?? '-';
                    order['aliciIl'] = shipmentDetails['il'] ?? '-';
                    order['aliciIlce'] = shipmentDetails['ilce'] ?? '-';
                    order['aliciNote'] = shipmentDetails['note'] ?? '-';
                    order['gonderenIsimSoyisim'] =
                        shipmentDetails['gonderenIsimSoyisim'] ?? '-';
                    order['gonderenKimlikNo'] =
                        shipmentDetails['gonderenKimlikNo'] ?? '-';
                    order['gonderiTarihi'] =
                        shipmentDetails['gonderiTarihi'] ?? '-';
                    order['kg'] = shipmentDetails['kg'] ?? '-';
                    allOrders.add(order);
                  }
                }
              });
            }
          });
        }
      }

      filteredOrders = List.from(allOrders);
    } catch (e) {
      print('Aktif siparişler yüklenirken hata oluştu: $e');
      Get.snackbar(
        'Hata',
        'Siparişler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading = false;
    update();
  }

  void filterOrders(String query) {
    searchText = query.toLowerCase();
    if (searchText.isEmpty) {
      filteredOrders = List.from(allOrders);
    } else {
      filteredOrders = allOrders.where((order) {
        final orderId = (order['orderId'] ?? '').toLowerCase();
        final content = (order['content'] ?? '').toLowerCase();
        final aliciIsimSoyisim =
            (order['aliciIsimSoyisim'] ?? '').toLowerCase();
        final aliciPhone = (order['aliciPhone'] ?? '').toLowerCase();
        final aliciAdres = (order['aliciAdres'] ?? '').toLowerCase();
        final aliciIl = (order['aliciIl'] ?? '').toLowerCase();
        final aliciIlce = (order['aliciIlce'] ?? '').toLowerCase();
        final aliciNote = (order['aliciNote'] ?? '').toLowerCase();
        final gonderenIsimSoyisim =
            (order['gonderenIsimSoyisim'] ?? '').toLowerCase();
        final gonderenKimlikNo =
            (order['gonderenKimlikNo'] ?? '').toLowerCase();
        final gonderiTarihi = (order['gonderiTarihi'] ?? '').toLowerCase();
        final kg = (order['kg'] ?? '').toLowerCase();

        return orderId.contains(searchText) ||
            content.contains(searchText) ||
            aliciIsimSoyisim.contains(searchText) ||
            aliciPhone.contains(searchText) ||
            aliciAdres.contains(searchText) ||
            aliciIl.contains(searchText) ||
            aliciIlce.contains(searchText) ||
            aliciNote.contains(searchText) ||
            gonderenIsimSoyisim.contains(searchText) ||
            gonderenKimlikNo.contains(searchText) ||
            gonderiTarihi.contains(searchText) ||
            kg.contains(searchText);
      }).toList();
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    searchText = '';
    filteredOrders = List.from(allOrders);
    update();
  }

  Future<void> updateOrderStatus(
      String userId, String orderId, String newStatus) async {
    try {
      await _shipmentsRef
          .child(userId)
          .child(orderId)
          .update({'packageStatus': newStatus});
      await loadActiveOrders();
      Get.snackbar(
        'Başarılı',
        'Sipariş durumu güncellendi: $newStatus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Sipariş durumu güncellenirken hata oluştu: $e');
      Get.snackbar(
        'Hata',
        'Sipariş durumu güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Siparişi teslim edildi olarak işaretle
  Future<void> markAsDelivered(String userId, String orderId) async {
    try {
      await _shipmentsRef.child(userId).child(orderId).update({
        'packageStatus': 'Gönderi Teslim Edildi',
        'delivery_date': DateTime.now().toIso8601String(),
        'delivered_by_admin': true,
      });
      await loadActiveOrders();
      Get.snackbar(
        'Başarılı',
        'Sipariş teslim edildi olarak işaretlendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Teslim işlemi sırasında hata: $e');
      Get.snackbar(
        'Hata',
        'Teslim işlemi sırasında bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Kuryeyi siparişten kaldır
  Future<void> removeCourierFromOrder(String userId, String orderId) async {
    try {
      await _shipmentsRef.child(userId).child(orderId).update({
        'packageStatus': 'Aktif',
        'kuryeUid': null,
        'kuryeIsimSoyisim': null,
        'kuryePhone': null,
        'kurye_assignment_date': null,
      });
      await loadActiveOrders();
      Get.snackbar(
        'Başarılı',
        'Kurye siparişten kaldırıldı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Kurye kaldırılırken hata: $e');
      Get.snackbar(
        'Hata',
        'Kurye kaldırılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Siparişi sil (sadece kurye atanmamışsa)
  Future<void> deleteOrder(
      String userId, String orderId, String? kuryeUid) async {
    if (kuryeUid != null && kuryeUid.isNotEmpty) {
      Get.snackbar(
        'Uyarı',
        'Bu siparişe kurye atanmış. Önce kuryeyi kaldırın.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _shipmentsRef.child(userId).child(orderId).remove();
      await loadActiveOrders();
      Get.snackbar(
        'Başarılı',
        'Sipariş silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Sipariş silinirken hata: $e');
      Get.snackbar(
        'Hata',
        'Sipariş silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
