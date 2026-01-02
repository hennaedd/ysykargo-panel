import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PendingCouriersController extends GetxController {
  List<Map<String, dynamic>> pendingCouriers = [];
  List<Map<String, dynamic>> allUsers = [];
  bool isLoading = false;

  // Filter
  String statusFilter =
      'pending'; // 'pending', 'approved', 'rejected', 'banned', 'all'

  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  @override
  void onInit() {
    super.onInit();
    loadPendingCouriers();
  }

  Future<void> loadPendingCouriers() async {
    isLoading = true;
    update();

    try {
      pendingCouriers.clear();
      allUsers.clear();

      final snapshot = await _usersRef.get();
      if (snapshot.exists) {
        final usersData = snapshot.value as Map?;
        if (usersData != null) {
          usersData.forEach((key, value) {
            if (value is Map) {
              final user = Map<String, dynamic>.from(value);
              user['uid'] = key;
              allUsers.add(user);

              // Sadece kuryeler ve belge yükleyenler
              final userType = user['user_type'] as String?;
              final documentsUploaded =
                  user['documents_uploaded'] as bool? ?? false;
              final accountStatus =
                  user['account_status'] as String? ?? 'pending';

              if (userType == 'Kurye' && documentsUploaded) {
                if (statusFilter == 'all' || accountStatus == statusFilter) {
                  pendingCouriers.add(user);
                }
              }
            }
          });
        }
      }

      // Tarihe göre sırala (en yeni en üstte)
      pendingCouriers.sort((a, b) {
        final dateA = a['documents_upload_date'] ?? '';
        final dateB = b['documents_upload_date'] ?? '';
        return dateB.compareTo(dateA);
      });
    } catch (e) {
      print('Bekleyen kuryeler yüklenirken hata: $e');
      Get.snackbar(
        'Hata',
        'Kuryeler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading = false;
    update();
  }

  void changeStatusFilter(String status) {
    statusFilter = status;
    loadPendingCouriers();
  }

  Future<void> approveCourier(String uid) async {
    try {
      await _usersRef.child(uid).update({
        'account_status': 'approved',
        'approval_date': DateTime.now().toIso8601String(),
      });

      await loadPendingCouriers();

      Get.snackbar(
        'Başarılı',
        'Kurye onaylandı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Kurye onaylanırken hata: $e');
      Get.snackbar(
        'Hata',
        'Kurye onaylanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> rejectCourier(String uid, String reason) async {
    try {
      await _usersRef.child(uid).update({
        'account_status': 'rejected',
        'rejection_reason': reason,
        'rejection_date': DateTime.now().toIso8601String(),
      });

      await loadPendingCouriers();

      Get.snackbar(
        'Başarılı',
        'Kurye reddedildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Kurye reddedilirken hata: $e');
      Get.snackbar(
        'Hata',
        'Kurye reddedilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> banUser(String uid, String reason) async {
    try {
      await _usersRef.child(uid).update({
        'account_status': 'banned',
        'ban_reason': reason,
        'ban_date': DateTime.now().toIso8601String(),
      });

      await loadPendingCouriers();

      Get.snackbar(
        'Başarılı',
        'Kullanıcı banlandı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Kullanıcı banlanırken hata: $e');
      Get.snackbar(
        'Hata',
        'Kullanıcı banlanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> unbanUser(String uid) async {
    try {
      await _usersRef.child(uid).update({
        'account_status': 'approved',
        'unban_date': DateTime.now().toIso8601String(),
      });

      // Ban bilgilerini temizle
      await _usersRef.child(uid).child('ban_reason').remove();
      await _usersRef.child(uid).child('ban_date').remove();

      await loadPendingCouriers();

      Get.snackbar(
        'Başarılı',
        'Kullanıcı banı kaldırıldı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Ban kaldırılırken hata: $e');
      Get.snackbar(
        'Hata',
        'Ban kaldırılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Önce kullanıcının aktif gönderisi var mı kontrol et
      final shipmentsRef = FirebaseDatabase.instance.ref().child('gönderiler');
      final shipmentsSnapshot = await shipmentsRef.get();

      bool hasActiveShipments = false;

      if (shipmentsSnapshot.exists) {
        final shipmentsData = shipmentsSnapshot.value as Map?;
        if (shipmentsData != null) {
          shipmentsData.forEach((userId, shipments) {
            if (shipments is Map) {
              shipments.forEach((orderId, shipmentDetails) {
                if (shipmentDetails is Map) {
                  final kuryeUid = shipmentDetails['kuryeUid'] as String?;
                  final packageStatus =
                      shipmentDetails['packageStatus'] as String?;

                  if (kuryeUid == uid &&
                      packageStatus != 'Gönderi Teslim Edildi') {
                    hasActiveShipments = true;
                  }
                }
              });
            }
          });
        }
      }

      if (hasActiveShipments) {
        Get.snackbar(
          'Uyarı',
          'Bu kuryenin aktif gönderisi var. Önce gönderileri başka kuryeye atayın veya tamamlayın.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      await _usersRef.child(uid).remove();
      await loadPendingCouriers();

      Get.snackbar(
        'Başarılı',
        'Kullanıcı silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Kullanıcı silinirken hata: $e');
      Get.snackbar(
        'Hata',
        'Kullanıcı silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'banned':
        return Colors.red.shade900;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String getStatusText(String? status) {
    switch (status) {
      case 'approved':
        return 'Onaylı';
      case 'rejected':
        return 'Reddedildi';
      case 'banned':
        return 'Banlı';
      case 'pending':
      default:
        return 'Onay Bekliyor';
    }
  }
}
