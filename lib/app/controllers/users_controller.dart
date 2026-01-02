import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  // Tüm kullanıcılar listesi
  List<Map<String, dynamic>> allUsers = [];

  // Filtrelenmiş kullanıcılar listesi
  List<Map<String, dynamic>> filteredUsers = [];

  // Yükleniyor durumu
  bool isLoading = false;

  // Arama metni
  String searchText = '';

  // Kullanıcı tipi filtresi (tümü, müşteri, kurye)
  String userTypeFilter = 'Tümü';

  // Firebase Realtime Database referansı
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  // Realtime Database'den kullanıcıları yükle
  Future<void> loadUsers() async {
    isLoading = true;
    update();

    try {
      final DataSnapshot snapshot = await _usersRef.get();

      if (snapshot.value != null) {
        // Realtime Database'den gelen veriyi Map'e dönüştür
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

        // Başlangıçta tüm kullanıcıları göster
        filteredUsers = List.from(allUsers);
      }
    } catch (e) {
      print('Kullanıcılar yüklenirken hata oluştu: $e');
    }

    isLoading = false;
    update();
  }

  // Kullanıcıları filtrele
  void filterUsers({String? searchQuery, String? userType}) {
    if (searchQuery != null) {
      searchText = searchQuery.toLowerCase();
    }

    if (userType != null) {
      userTypeFilter = userType;
    }

    // Önce kullanıcı tipine göre filtrele
    if (userTypeFilter == 'Tümü') {
      filteredUsers = List.from(allUsers);
    } else {
      filteredUsers = allUsers.where((user) => user['user_type']?.toLowerCase() == userTypeFilter.toLowerCase()).toList();
    }

    // Sonra arama metnine göre filtrele
    if (searchText.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        // Arama metnine göre filtreleme
        final name = (user['name'] ?? '').toLowerCase();
        final surname = (user['surname'] ?? '').toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        final phone = (user['phone'] ?? '').toLowerCase();
        final vehicleType = (user['vehicle_type'] ?? '').toLowerCase();

        return name.contains(searchText) ||
            surname.contains(searchText) ||
            email.contains(searchText) ||
            phone.contains(searchText) ||
            vehicleType.contains(searchText);
      }).toList();
    }

    update();
  }

  // Arama metnini temizle
  void clearSearch() {
    searchText = '';
    filterUsers(searchQuery: '');
  }

  // Kullanıcı tipi filtresini değiştir
  void changeUserTypeFilter(String userType) {
    userTypeFilter = userType;
    filterUsers(userType: userType);
  }
}
