import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OrderSearchController extends GetxController {
  // Bulunan siparişler
  List<Map<String, dynamic>> foundOrders = [];
  Map<String, dynamic>? selectedOrder;

  // Yükleniyor durumu
  bool isLoading = false;

  // Arama yapıldı mı?
  bool hasSearched = false;

  // Arama controller'ı
  late TextEditingController searchController;

  // Firebase Realtime Database referansı
  final DatabaseReference _shipmentsRef = FirebaseDatabase.instance.ref().child('gönderiler');
  final DatabaseReference _completedOrdersRef = FirebaseDatabase.instance.ref().child('tamamlanan_siparisler');

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Sipariş numarasına göre ara (tam veya kısmi eşleşme)
  Future<void> searchOrder(String query) async {
    if (query.isEmpty) {
      foundOrders = [];
      selectedOrder = null;
      hasSearched = false;
      update();
      return;
    }

    isLoading = true;
    hasSearched = true;
    foundOrders = [];
    selectedOrder = null;
    update();

    try {
      // Aktif siparişlerde ara
      await _searchInActiveOrders(query.toLowerCase());

      // Tamamlanan siparişlerde ara
      await _searchInCompletedOrders(query.toLowerCase());
    } catch (e) {
      print('Sipariş arama hatası: $e');
    }

    isLoading = false;
    update();
  }

  // Aktif siparişlerde ara
  Future<void> _searchInActiveOrders(String query) async {
    final DataSnapshot snapshot = await _shipmentsRef.get();

    if (snapshot.value != null) {
      final dynamic shipmentsData = snapshot.value;

      if (shipmentsData is Map) {
        for (final userId in shipmentsData.keys) {
          final userShipments = shipmentsData[userId];

          if (userShipments is Map) {
            userShipments.forEach((orderId, orderData) {
              if (orderData is Map && orderId.toString().toLowerCase().contains(query) && orderData['packageStatus'] != 'Gönderi Teslim Edildi') {
                final Map<String, dynamic> order = Map<String, dynamic>.from(orderData);
                order['orderId'] = orderId;
                order['userId'] = userId;
                order['orderSource'] = 'active';
                foundOrders.add(order);
              }
            });
          }
        }
      }
    }
  }

  // Tamamlanan siparişlerde ara
  Future<void> _searchInCompletedOrders(String query) async {
    final DataSnapshot snapshot = await _completedOrdersRef.get();

    if (snapshot.value != null) {
      final dynamic completedOrdersData = snapshot.value;

      if (completedOrdersData is Map) {
        for (final userId in completedOrdersData.keys) {
          final userOrders = completedOrdersData[userId];

          if (userOrders is Map) {
            userOrders.forEach((orderId, orderData) {
              if (orderData is Map && orderId.toString().toLowerCase().contains(query)) {
                final Map<String, dynamic> order = Map<String, dynamic>.from(orderData);
                order['orderId'] = orderId;
                order['userId'] = userId;
                order['orderSource'] = 'completed';
                foundOrders.add(order);
              }
            });
          }
        }
      }
    }
  }

  // Bir siparişi seç
  void selectOrder(Map<String, dynamic> order) {
    selectedOrder = order;
    update();
  }

  // Temizle
  void clearSearch() {
    searchController.clear();
    foundOrders = [];
    selectedOrder = null;
    hasSearched = false;
    update();
  }

  // Siparişi sil
  Future<void> deleteOrder(String userId, String orderId, String orderSource) async {
    try {
      isLoading = true;
      update();

      if (orderSource == 'active') {
        // Aktif siparişlerden sil
        await _shipmentsRef.child(userId).child(orderId).remove();
      } else if (orderSource == 'completed') {
        // Tamamlanan siparişlerden sil
        await _completedOrdersRef.child(userId).child(orderId).remove();
      }

      // Arama sonuçlarını güncelle
      if (searchController.text.isNotEmpty) {
        await searchOrder(searchController.text);
      } else {
        clearSearch();
      }

      selectedOrder = null;

      Get.snackbar(
        'Başarılı',
        'Sipariş silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Sipariş silinirken hata oluştu: $e');
      Get.snackbar(
        'Hata',
        'Sipariş silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }
}
