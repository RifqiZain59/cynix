import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// IMPORT HALAMAN YANG DIBUTUHKAN
import '../../login/views/login_view.dart';
// Sesuaikan path ini dengan letak folder PersetujuandefaultaplikasiView kamu:
import '../../persetujuandefaultaplikasi/views/persetujuandefaultaplikasi_view.dart';

class RegisterController extends GetxController {
  final box = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  // ============================================================
  // FUNGSI REGISTER MANUAL (EMAIL & PASSWORD)
  // ============================================================
  Future<void> register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar("Peringatan", "Semua kolom wajib diisi", Colors.orange);
      return;
    }

    if (password.length < 6) {
      _showSnackbar(
        "Password Lemah",
        "Password minimal 6 karakter",
        Colors.redAccent,
      );
      return;
    }

    isLoading.value = true;

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'protectionLevel': 0,
      });

      // Sign out agar user dipaksa masuk manual
      await _auth.signOut();

      _showSnackbar(
        "Berhasil",
        "Akun berhasil dibuat! Silakan masuk.",
        Colors.green,
      );

      // Arahkan ke Halaman Login (Import Class)
      Get.offAll(() => LoginView());
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";
      if (e.code == 'weak-password')
        message = "Password terlalu lemah";
      else if (e.code == 'email-already-in-use')
        message = "Email sudah terdaftar";

      _showSnackbar("Registrasi Gagal", message, Colors.redAccent);
    } catch (e) {
      _showSnackbar("Error", e.toString(), Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FUNGSI REGISTER & LOGIN DENGAN GOOGLE
  // ============================================================
  Future<void> registerWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? "User Google",
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Simpan Sesi Lokal
        box.write('isLoggedIn', true);
        box.write('userName', user.displayName ?? "User Google");
        box.write('uid', user.uid);

        _showSnackbar(
          "Berhasil",
          "Masuk dengan Google berhasil!",
          Colors.green,
        );

        // ============================================================
        // PERUBAHAN DI SINI: ARAHKAN KE HALAMAN PERSETUJUAN DEFAULT
        // ============================================================
        Get.offAll(() => PersetujuandefaultaplikasiView());
      }
    } catch (e) {
      _showSnackbar("Google Login Gagal", e.toString(), Colors.redAccent);
      debugPrint("DETAIL ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String msg, Color color) {
    Get.snackbar(title, msg, backgroundColor: color, colorText: Colors.white);
  }
}
