import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CustomerShipmentsController extends GetxController {
  // Seçili kullanıcı ID'si
  String? selectedUserId;

  // Seçili kullanıcı bilgileri
  Map<String, dynamic>? selectedUserInfo;

  // Kullanıcıya ait gönderiler
  List<Map<String, dynamic>> customerShipments = [];

  // Filtrelenmiş gönderiler
  List<Map<String, dynamic>> filteredShipments = [];

  // Kullanıcı arama sonuçları
  List<Map<String, dynamic>> searchResults = [];

  // Yükleniyor durumu
  bool isLoading = false;
  bool isSearching = false;

  // Aktif gönderileri mi gösteriliyoruz?
  bool viewingActiveShipments = true;

  // Arama metni
  String searchText = '';

  // Arama alanı controller'ları
  late TextEditingController userSearchController;
  late TextEditingController shipmentSearchController;

  // Firebase Realtime Database referansları
  final DatabaseReference _shipmentsRef = FirebaseDatabase.instance.ref().child('gönderiler');
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');

  @override
  void onInit() {
    super.onInit();
    userSearchController = TextEditingController();
    shipmentSearchController = TextEditingController();
  }

  @override
  void onClose() {
    userSearchController.dispose();
    shipmentSearchController.dispose();
    super.onClose();
  }

  // Kullanıcı ara
  Future<void> searchUser(String query) async {
    searchText = query;
    userSearchController.text = query;

    if (query.isEmpty) {
      searchResults = [];
      update();
      return;
    }

    isSearching = true;
    update();

    try {
      final DataSnapshot snapshot = await _usersRef.get();

      if (snapshot.value != null) {
        final dynamic usersData = snapshot.value;
        searchResults = [];

        if (usersData is Map) {
          usersData.forEach((userId, userData) {
            if (userData is Map) {
              final Map<String, dynamic> user = Map<String, dynamic>.from(userData);
              user['uid'] = userId;

              // Kullanıcı bilgilerinde arama yap
              final name = ((user['name'] ?? '') + ' ' + (user['surname'] ?? '')).toLowerCase();
              final email = (user['email'] ?? '').toString().toLowerCase();
              final phone = (user['phone'] ?? '').toString().toLowerCase();

              if (name.contains(query.toLowerCase()) || email.contains(query.toLowerCase()) || phone.contains(query.toLowerCase())) {
                searchResults.add(user);
              }
            }
          });
        }
      }
    } catch (e) {
      print('Kullanıcı arama hatası: $e');
    }

    isSearching = false;
    update();
  }

  // Bir kullanıcıyı seç
  void selectUser(Map<String, dynamic> user) {
    selectedUserId = user['uid'] as String;
    selectedUserInfo = user;
    viewingActiveShipments = true;
    loadCustomerShipments(selectedUserId!);
  }

  // Seçili kullanıcıyı temizle
  void clearSelectedUser() {
    selectedUserId = null;
    selectedUserInfo = null;
    customerShipments = [];
    filteredShipments = [];
    userSearchController.clear();
    shipmentSearchController.clear();
    searchText = '';
    update();
  }

  // Kullanıcı ID'sine göre gönderileri yükle
  Future<void> loadCustomerShipments(String userId) async {
    selectedUserId = userId;
    isLoading = true;
    viewingActiveShipments = true;
    shipmentSearchController.clear();
    update();

    try {
      final DataSnapshot snapshot = await _shipmentsRef.child(userId).get();

      customerShipments = [];

      if (snapshot.value != null) {
        final dynamic shipmentsData = snapshot.value;

        if (shipmentsData is Map) {
          shipmentsData.forEach((shipmentId, shipmentData) {
            if (shipmentData is Map) {
              final Map<String, dynamic> shipment = Map<String, dynamic>.from(shipmentData);
              shipment['orderId'] = shipmentId;
              if (shipment['packageStatus'] != 'Gönderi Teslim Edildi') {
                customerShipments.add(shipment);
              }
            }
          });
        }
      }

      filteredShipments = List.from(customerShipments);
    } catch (e) {
      print('Müşteri gönderileri yüklenirken hata oluştu: $e');
    }

    isLoading = false;
    update();
  }

  // Tamamlanan siparişleri yükle
  Future<void> loadCompletedShipments(String userId) async {
    selectedUserId = userId;
    isLoading = true;
    viewingActiveShipments = false;
    shipmentSearchController.clear();
    update();
    try {
      final DataSnapshot snapshot = await _shipmentsRef.child(userId).get();
      customerShipments = [];
      if (snapshot.value != null) {
        final dynamic shipmentsData = snapshot.value;

        if (shipmentsData is Map) {
          shipmentsData.forEach((shipmentId, shipmentData) {
            if (shipmentData is Map) {
              final Map<String, dynamic> shipment = Map<String, dynamic>.from(shipmentData);
              shipment['orderId'] = shipmentId;
              if (shipment['packageStatus'] == 'Gönderi Teslim Edildi') {
                customerShipments.add(shipment);
              }
            }
          });
        }
      }

      filteredShipments = List.from(customerShipments);
    } catch (e) {
      print('Tamamlanan siparişler yüklenirken hata oluştu: $e');
    }

    isLoading = false;
    update();
  }

  // Gönderileri filtrele
  void filterShipments(String query) {
    searchText = query.toLowerCase();
    shipmentSearchController.text = query;

    if (searchText.isEmpty) {
      filteredShipments = List.from(customerShipments);
    } else {
      filteredShipments = customerShipments.where((shipment) {
        // Arama metnine göre filtreleme
        final content = (shipment['content'] ?? '').toString().toLowerCase();
        final aliciIsimSoyisim = (shipment['aliciIsimSoyisim'] ?? '').toString().toLowerCase();
        final aliciPhone = (shipment['aliciPhone'] ?? '').toString().toLowerCase();
        final aliciAdres = (shipment['aliciAdres'] ?? '').toString().toLowerCase();
        final aliciIl = (shipment['aliciIl'] ?? '').toString().toLowerCase();
        final aliciIlce = (shipment['aliciIlce'] ?? '').toString().toLowerCase();
        final packageStatus = (shipment['packageStatus'] ?? '').toString().toLowerCase();
        final shipmentId = (shipment['shipmentId'] ?? '').toString().toLowerCase();

        return content.contains(searchText) ||
            aliciIsimSoyisim.contains(searchText) ||
            aliciPhone.contains(searchText) ||
            aliciAdres.contains(searchText) ||
            aliciIl.contains(searchText) ||
            aliciIlce.contains(searchText) ||
            packageStatus.contains(searchText) ||
            shipmentId.contains(searchText);
      }).toList();
    }

    update();
  }

  // Arama metnini temizle
  void clearSearch() {
    if (selectedUserId == null) {
      // Kullanıcı araması temizleniyor
      userSearchController.clear();
      searchResults = [];
    } else {
      // Gönderi araması temizleniyor
      shipmentSearchController.clear();
      filteredShipments = List.from(customerShipments);
    }
    searchText = '';
    update();
  }
}
