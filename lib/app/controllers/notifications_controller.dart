import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  // Form controllers
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  // Loading state
  bool isLoading = false;

  // Selected app type
  String selectedAppType = 'Tümü'; // 'Tümü', 'Müşteri', 'Kurye'

  // Notification history
  List<Map<String, dynamic>> notificationHistory = [];

  // Firebase reference
  final DatabaseReference _notificationsRef =
      FirebaseDatabase.instance.ref().child('notifications');

  @override
  void onInit() {
    super.onInit();
    loadNotificationHistory();
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  Future<void> loadNotificationHistory() async {
    try {
      final snapshot = await _notificationsRef
          .orderByChild('timestamp')
          .limitToLast(50)
          .get();
      notificationHistory.clear();

      if (snapshot.exists) {
        final data = snapshot.value as Map?;
        if (data != null) {
          data.forEach((key, value) {
            if (value is Map) {
              final notification = Map<String, dynamic>.from(value);
              notification['id'] = key;
              notificationHistory.add(notification);
            }
          });
          // En yeni en üstte
          notificationHistory.sort(
            (a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0),
          );
        }
      }
      update();
    } catch (e) {
      print('Bildirim geçmişi yüklenirken hata: $e');
    }
  }

  void changeAppType(String type) {
    selectedAppType = type;
    update();
  }

  Future<void> sendNotification() async {
    if (titleController.text.isEmpty || bodyController.text.isEmpty) {
      Get.snackbar(
        'Hata',
        'Lütfen başlık ve içerik alanlarını doldurun',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading = true;
    update();

    try {
      // Bildirimi Firebase'e kaydet
      // Cloud Function bu kaydı dinleyip FCM üzerinden gönderim yapacaktır.
      final notificationData = {
        'title': titleController.text,
        'body': bodyController.text,
        'targetType': selectedAppType,
        'timestamp': ServerValue.timestamp,
        'sentBy': 'admin',
        // 'recipientCount' artık Cloud Function tarafından hesaplanabilir veya tahmini bir değer girilebilir.
        // Şimdilik boş bırakıyoruz veya kaldıyoruz.
      };

      await _notificationsRef.push().set(notificationData);

      // Bildirim geçmişini yenile
      await loadNotificationHistory();

      // Formu temizle
      titleController.clear();
      bodyController.clear();

      Get.snackbar(
        'Başarılı',
        'Bildirim sisteme başarıyla kaydedildi ve gönderim sırasına alındı.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Bildirim gönderilirken hata: $e');
      Get.snackbar(
        'Hata',
        'Bildirim gönderilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading = false;
    update();
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.child(notificationId).remove();
      await loadNotificationHistory();

      Get.snackbar(
        'Başarılı',
        'Bildirim silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Bildirim silinirken hata: $e');
      Get.snackbar(
        'Hata',
        'Bildirim silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
