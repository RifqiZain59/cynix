import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../login/views/login_view.dart'; // Import halaman Login untuk Logout

class ProfileController extends GetxController {
  // Inisialisasi Firebase & Storage
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage();

  // State Reaktif untuk menyimpan data dari Firestore
  var userName = 'Memuat...'.obs;
  var userEmail = 'Memuat...'.obs;
  var protectionLevel = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile(); // Ambil data profil saat halaman pertama kali dibuka
  }

  // ============================================================
  // FUNGSI MENGAMBIL DATA DARI FIRESTORE
  // ============================================================
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      // Ambil UID dari Firebase Auth, atau dari GetStorage jika Auth belum siap
      String? uid = _auth.currentUser?.uid ?? box.read('uid');

      if (uid != null) {
        // Tarik dokumen pengguna dari koleksi 'users'
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(uid)
            .get();

        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          userName.value = data['name'] ?? 'User Cynix';
          userEmail.value = data['email'] ?? 'Email tidak tersedia';
          protectionLevel.value = data['protectionLevel'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil data profil: $e");
      Get.snackbar(
        "Error",
        "Gagal memuat data profil",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FUNGSI LOGOUT (KELUAR APLIKASI)
  // ============================================================
  Future<void> logout() async {
    try {
      // 1. Sign out dari Firebase
      await _auth.signOut();

      // 2. Sign out dari Google (Mencegah akun lama nyangkut jika login Google lagi)
      await GoogleSignIn().signOut();

      // 3. Bersihkan memori lokal (GetStorage)
      box.write('isLoggedIn', false);
      box.remove('uid');
      box.remove('userName');

      // 4. Arahkan kembali ke Halaman Login
      Get.offAll(() => LoginView());
    } catch (e) {
      debugPrint("Gagal logout: $e");
      Get.snackbar(
        "Error",
        "Gagal keluar dari aplikasi",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
