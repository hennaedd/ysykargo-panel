import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserSearchController extends GetxController {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  String searchType = 'Tümü';
  
  // TextEditingControllers for each search field
  final Map<String, TextEditingController> textControllers = {
    'name': TextEditingController(),
    'surname': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'vehicle_type': TextEditingController(),
  };

  // Arama filtreleri (controller ile senkronize edilecek)
  Map<String, String> searchFilters = {
    'name': '',
    'surname': '',
    'email': '',
    'phone': '',
    'vehicle_type': '',
  };

  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');

  @override
  void onInit() {
    super.onInit();
    // Initialize listeners to sync controllers with searchFilters
    textControllers.forEach((key, controller) {
      controller.addListener(() {
        searchFilters[key] = controller.text;
      });
    });
    loadAllUsers();
  }

  @override
  void onClose() {
    // Clean up controllers when the controller is disposed
    textControllers.forEach((_, controller) => controller.dispose());
    super.onClose();
  }

  Future<void> loadAllUsers() async {
    isLoading = true;
    update();

    try {
      final DataSnapshot snapshot = await _usersRef.get();

      if (snapshot.value != null) {
        final dynamic usersData = snapshot.value;
        allUsers = [];

        if (usersData is Map) {
          usersData.forEach((key, value) {
            if (value is Map) {
              final Map<String, dynamic> userData = Map<String, dynamic>.from(value);
              userData['uid'] = key;
              allUsers.add(userData);
            }
          });
        }
      }
    } catch (e) {
      print('Kullanıcılar yüklenirken hata oluştu: $e');
    }

    isLoading = false;
    update();
  }

  void changeSearchType(String type) {
    searchType = type;
    if (type == 'Kurye' && searchFilters['vehicle_type']!.isEmpty) {
      searchFilters['vehicle_type'] = '';
      textControllers['vehicle_type']!.text = '';
    }
    update();
  }

  void updateSearchFilter(String key, String value) {
    searchFilters[key] = value;
    // Sync the controller with the new value (only if different)
    if (textControllers[key]!.text != value) {
      textControllers[key]!.text = value;
    }
    // No need to call update() here to prevent rebuild on every keystroke
  }

  void clearFilters() {
    searchFilters.forEach((key, _) {
      searchFilters[key] = '';
      textControllers[key]!.text = '';
    });
    update();
  }

  void searchUsers() {
    isLoading = true;
    update();

    searchResults = allUsers.where((user) {
      if (searchType != 'Tümü') {
        if (user['user_type'] != searchType) {
          return false;
        }
      }

      bool matchesFilters = true;
      searchFilters.forEach((key, value) {
        if (value.isNotEmpty) {
          final userValue = (user[key] ?? '').toString().toLowerCase();
          if (!userValue.contains(value.toLowerCase())) {
            matchesFilters = false;
          }
        }
      });

      return matchesFilters;
    }).toList();

    isLoading = false;
    update();
  }
}