import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/routes/route_manager.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    hidePassword = !hidePassword;
    update();
  }

  Future<void> login() async {
    // Giriş işlemini simüle etmek için loading gösteriyoruz
    isLoading = true;
    update();

    // E-posta ve şifre doğrulaması yapıyoruz
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Hata',
        'E-posta ve şifre alanları boş bırakılamaz.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading = false;
      update();
      return;
    }

    try {
      // Firebase'den admin bilgilerini kontrol et
      bool isAuthenticated = await _checkAdminCredentials(
        emailController.text,
        passwordController.text,
      );

      if (isAuthenticated) {
        // Başarılı giriş durumunda ana sayfaya yönlendirme yapacağız
        await Future.delayed(
            const Duration(seconds: 1)); // Yükleme animasyonu görmek için
        navigateToHomePage();
      } else {
        Get.snackbar(
          'Hata',
          'Geçersiz e-posta veya şifre!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Login hatası: $e');
      Get.snackbar(
        'Hata',
        'Giriş yaparken bir sorun oluştu. Lütfen tekrar deneyin.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading = false;
    update();
  }

  Future<bool> _checkAdminCredentials(String email, String password) async {
    // Varsayılan admin bilgileri - her zaman çalışır
    const defaultEmail = 'admin@admin.com';
    const defaultPassword = '123456';

    // Önce varsayılan bilgilerle kontrol et
    if (email == defaultEmail && password == defaultPassword) {
      return true;
    }

    // Varsayılan bilgiler eşleşmezse Firebase'den kontrol et
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('admin')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final storedEmail = data['email'] as String? ?? '';
        final storedPassword = data['password'] as String? ?? '';

        return email == storedEmail && password == storedPassword;
      }
    } catch (e) {
      print('Firebase admin kontrol hatası: $e');
    }

    return false;
  }

  void navigateToHomePage() {
    // Ana sayfaya geçiş yapıyoruz
    Get.offAllNamed(RouteManager.instance.homePage);
  }
}
