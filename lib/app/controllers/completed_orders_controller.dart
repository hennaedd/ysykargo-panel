import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class CompletedOrdersController extends GetxController {
  List<Map<String, dynamic>> allCompletedOrders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = false;
  String searchText = '';
  late TextEditingController searchController;
  Timer? _debounce;

  final DatabaseReference _completedOrdersRef = FirebaseDatabase.instance.ref().child('tamamlanan_siparisler');

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    // Add listener with debounce
    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        filterOrders(searchController.text);
      });
    });
    loadCompletedOrders();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadCompletedOrders() async {
    isLoading = true;
    update();

    try {
      final DataSnapshot snapshot = await _completedOrdersRef.get();

      if (snapshot.value != null) {
        final dynamic ordersData = snapshot.value;
        allCompletedOrders = [];

        if (ordersData is Map) {
          ordersData.forEach((userId, orders) {
            if (orders is Map) {
              orders.forEach((orderId, orderData) {
                if (orderData is Map) {
                  final Map<String, dynamic> orderMap = Map<String, dynamic>.from(orderData);
                  orderMap['orderId'] = orderId;
                  orderMap['userId'] = userId;
                  allCompletedOrders.add(orderMap);
                }
              });
            }
          });
        }

        filteredOrders = List.from(allCompletedOrders);
        // Ensure search controller is empty after loading
        if (searchController.text.isEmpty) {
          searchText = '';
        }
      }
    } catch (e) {
      print('Tamamlanan siparişler yüklenirken hata oluştu: $e');
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
    final queryLower = query.trim().toLowerCase();
    searchText = queryLower;

    if (queryLower.isEmpty) {
      filteredOrders = List.from(allCompletedOrders);
    } else {
      final searchTerms = queryLower.split(' ');

      filteredOrders = allCompletedOrders.where((order) {
        final fields = {
          'content': order['content'] ?? '',
          'aliciIsimSoyisim': order['aliciIsimSoyisim'] ?? '',
          'aliciPhone': order['aliciPhone'] ?? '',
          'aliciAdres': order['aliciAdres'] ?? '',
          'aliciIl': order['aliciIl'] ?? '',
          'aliciIlce': order['aliciIlce'] ?? '',
          'orderId': order['orderId'] ?? '',
          'packageStatus': order['packageStatus'] ?? '',
        };

        final searchableText = fields.values
            .map((value) => value.toString().toLowerCase())
            .join(' ');

        return searchTerms.every((term) => searchableText.contains(term));
      }).toList();

      // Sort results by relevance (orderId first)
      filteredOrders.sort((a, b) {
        final aId = (a['orderId'] ?? '').toString().toLowerCase();
        final bId = (b['orderId'] ?? '').toString().toLowerCase();
        if (aId.startsWith(queryLower) && !bId.startsWith(queryLower)) return -1;
        if (!aId.startsWith(queryLower) && bId.startsWith(queryLower)) return 1;
        return aId.compareTo(bId);
      });
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    searchText = '';
    filteredOrders = List.from(allCompletedOrders);
    update();
  }
}