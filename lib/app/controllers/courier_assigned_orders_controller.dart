import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourierAssignedOrdersController extends GetxController {
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = false;
  String searchText = '';
  late TextEditingController searchController;
  Timer? _debounce;

  final DatabaseReference _shipmentsRef =
      FirebaseDatabase.instance.ref().child('gönderiler');
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
    loadCourierAssignedOrders();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');

  Future<void> loadCourierAssignedOrders() async {
    isLoading = true;
    update();

    try {
      final DataSnapshot snapshot = await _shipmentsRef.get();
      final DataSnapshot usersSnapshot = await _usersRef.get(); // Fetch users

      if (snapshot.value != null) {
        final dynamic shipmentsData = snapshot.value;
        Map<dynamic, dynamic> usersData = {};
        if (usersSnapshot.value != null) {
          usersData = usersSnapshot.value as Map<dynamic, dynamic>;
        }

        allOrders = [];

        if (shipmentsData is Map) {
          shipmentsData.forEach((userId, shipments) {
            if (shipments is Map) {
              shipments.forEach((orderId, orderData) {
                if (orderData is Map) {
                  final Map<String, dynamic> orderMap =
                      Map<String, dynamic>.from(orderData);

                  // Package status check
                  if (orderMap['packageStatus'] != 'Aktif' &&
                      orderMap['packageStatus'] != 'Gönderi Teslim Edildi') {
                    orderMap['orderId'] = orderId;
                    orderMap['uid'] = userId;

                    // Enrich with courier info if kuryeUid exists and name is missing/empty
                    if (orderMap.containsKey('kuryeUid') &&
                        orderMap['kuryeUid'] != null) {
                      final kuryeUid = orderMap['kuryeUid'];
                      if (usersData.containsKey(kuryeUid)) {
                        final courierData = usersData[kuryeUid] as Map;
                        // Get name from User data
                        // Get name from User data (Try both name formats)
                        final firstName = courierData['first_name'] ??
                            courierData['name'] ??
                            '';
                        final lastName = courierData['last_name'] ??
                            courierData['surname'] ??
                            '';
                        final fullName = '$firstName $lastName'.trim();

                        if (fullName.isNotEmpty) {
                          orderMap['kuryeIsimSoyisim'] = fullName;
                        }
                      }
                    }

                    allOrders.add(orderMap);
                  }
                }
              });
            }
          });
        }

        filteredOrders = List.from(allOrders);
        if (searchController.text.isEmpty) {
          searchText = '';
        } else {
          // Re-apply filter if there was a search
          filterOrders(searchController.text);
        }
      }
    } catch (e) {
      print('Kuryeye atanmış siparişler yüklenirken hata oluştu: $e');
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
      filteredOrders = List.from(allOrders);
    } else {
      final searchTerms = queryLower.split(' ');

      filteredOrders = allOrders.where((order) {
        final fields = {
          'content': order['content'] ?? '',
          'aliciIsimSoyisim': order['aliciIsimSoyisim'] ?? '',
          'aliciPhone': order['aliciPhone'] ?? '',
          'aliciAdres': order['aliciAdres'] ?? '',
          'aliciIl': order['aliciIl'] ?? '',
          'aliciIlce': order['aliciIlce'] ?? '',
          'orderId': order['orderId'] ?? '',
          'packageStatus': order['packageStatus'] ?? '',
          'kurye': order['kurye'] ?? '',
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
        if (aId.startsWith(queryLower) && !bId.startsWith(queryLower))
          return -1;
        if (!aId.startsWith(queryLower) && bId.startsWith(queryLower)) return 1;
        return aId.compareTo(bId);
      });
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    searchText = '';
    filteredOrders = List.from(allOrders);
    update();
    Get.snackbar(
      'Bilgi',
      'Arama temizlendi',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }
}
