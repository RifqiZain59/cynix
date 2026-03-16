import 'package:cynix/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PersetujuandefaultaplikasiController extends GetxController {
  // Jalur komunikasi ke sistem Android (Kotlin)
  static const platform = MethodChannel('com.cynix.app/call_screening');

  Future<void> requestDefaultDialer() async {
    try {
      // 1. Memicu munculnya Pop-up Role Dialer Bawaan Sistem Android
      final String result = await platform.invokeMethod('requestRole');
      debugPrint("Hasil eksekusi: $result");

      // 2. JIKA BERHASIL, pindah menggunakan Named Route agar Binding ikut dimuat
      Get.offAllNamed(Routes.HOME);

      Get.snackbar(
        "Sistem Aktif",
        "Cynix sekarang menjadi aplikasi telepon default Anda.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on PlatformException catch (e) {
      // JIKA GAGAL / DIBATALKAN oleh User
      Get.snackbar(
        "Dibatalkan",
        "Cynix gagal ditetapkan sebagai default. ${e.message}",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
