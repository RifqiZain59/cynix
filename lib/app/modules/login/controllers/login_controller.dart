import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In

// Pastikan path ini sesuai dengan letak folder kamu
import '../../persetujuandefaultaplikasi/views/persetujuandefaultaplikasi_view.dart';

class LoginController extends GetxController {
  // 1. Inisialisasi Firebase & Storage
  final box = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. Controller untuk input teks
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 3. State Reaktif
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Fungsi Toggle Mata Password
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // ============================================================
  // FUNGSI LOGIN MANUAL (EMAIL & PASSWORD)
  // ============================================================
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Error", "Email dan Password wajib diisi", Colors.orange);
      return;
    }

    isLoading.value = true;

    try {
      // 1. Login ke Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2. Ambil data nama dari Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      String name = "User Cynix"; // Nama default jika gagal ambil

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        name = data['name'] ?? "User Cynix";
      }

      // 3. Simpan Sesi Lokal (GetStorage)
      box.write('isLoggedIn', true);
      box.write('userName', name);
      box.write('uid', uid);

      _showSnackbar("Berhasil", "Selamat datang kembali, $name!", Colors.green);

      // 4. Arahkan ke Halaman Persetujuan Default
      Get.offAll(() => PersetujuandefaultaplikasiView());
    } on FirebaseAuthException catch (e) {
      String message = "Email atau Password salah";
      if (e.code == 'user-not-found')
        message = "Pengguna tidak ditemukan";
      else if (e.code == 'wrong-password')
        message = "Password salah";
      else if (e.code == 'invalid-credential')
        message = "Kredensial tidak valid";

      _showSnackbar("Login Gagal", message, Colors.redAccent);
      debugPrint("FIREBASE AUTH ERROR: ${e.code}");
    } catch (e) {
      _showSnackbar("Error", "Terjadi kesalahan sistem: $e", Colors.redAccent);
      debugPrint("GENERAL ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FUNGSI LOGIN DENGAN GOOGLE
  // ============================================================
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      // 1. Inisialisasi GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // 2. Munculkan popup pilih akun
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return; // Dibatalkan oleh user
      }

      // 3. Ambil detail otentikasi dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Buat kredensial untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in ke Firebase menggunakan kredensial Google
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        // 6. Ambil data dari Firestore (Mengecek apakah dia sudah pernah daftar)
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        String name = user.displayName ?? "User Google";

        if (userDoc.exists) {
          // Jika sudah ada, pakai nama dari database
          var data = userDoc.data() as Map<String, dynamic>;
          name = data['name'] ?? name;
        } else {
          // Jika belum ada di Firestore (Login perdana pakai Google), buatkan datanya
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'protectionLevel': 0,
          });
        }

        // 7. Simpan Sesi Lokal
        box.write('isLoggedIn', true);
        box.write('userName', name);
        box.write('uid', user.uid);

        _showSnackbar(
          "Berhasil",
          "Selamat datang kembali, $name!",
          Colors.green,
        );

        // 8. Arahkan ke Halaman Persetujuan Default
        Get.offAll(() => PersetujuandefaultaplikasiView());
      }
    } catch (e) {
      _showSnackbar(
        "Google Login Gagal",
        "Terjadi kesalahan. Pastikan koneksi aman. Error: $e",
        Colors.redAccent,
      );
      debugPrint("ERROR GOOGLE LOGIN: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // HELPER UNTUK SNACKBAR AGAR KODE BERSIH
  // ============================================================
  void _showSnackbar(String title, String msg, Color color) {
    Get.snackbar(
      title,
      msg,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
