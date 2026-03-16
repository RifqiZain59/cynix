import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Jalur komunikasi ke sistem Android (Kotlin)
  static const platform = MethodChannel('com.cynix.app/call_screening');

  // Variabel untuk UI
  var isLoading = false.obs;
  var callLogs = <CallLogModel>[].obs;

  // Tingkat Perlindungan: 0 (Rendah), 1 (Menengah), 2 (Aman/Hijau)
  var protectionLevel = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedLogs();

    // WAJIB: Cek status asli HP saat aplikasi dibuka!
    checkSystemRoles();
  }

  // ============================================================
  // FUNGSI BARU: CEK STATUS DEFAULT ASLI DARI ANDROID
  // ============================================================
  Future<void> checkSystemRoles() async {
    try {
      // Meminta Kotlin mengecek: Apakah sudah default Dialer? Default SMS?
      // Kotlin akan membalas dengan angka: 0, 1, atau 2
      final int level = await platform.invokeMethod('checkRoles');
      protectionLevel.value = level;
    } on PlatformException catch (e) {
      debugPrint("Gagal mengecek role sistem: ${e.message}");
    }
  }

  // ============================================================
  // FUNGSI 1: AKTIVASI DEFAULT TELEPON
  // ============================================================
  Future<void> activateSpamBlocking() async {
    try {
      // Memanggil fungsi requestRole di Kotlin (ROLE_DIALER)
      await platform.invokeMethod('requestRole');

      // JIKA BERHASIL: Cek ulang status ke sistem (memastikan berubah jadi 1)
      await checkSystemRoles();

      Get.snackbar(
        "Berhasil",
        "Cynix sekarang menjadi aplikasi Telepon utama Anda.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on PlatformException catch (e) {
      Get.snackbar(
        "Dibatalkan",
        "Akses Telepon belum diberikan.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // FUNGSI 2: AKTIVASI DEFAULT SMS
  // ============================================================
  Future<void> activateSmsBlocking() async {
    try {
      // Memanggil fungsi requestSmsRole di Kotlin (ROLE_SMS)
      await platform.invokeMethod('requestSmsRole');

      // JIKA BERHASIL: Cek ulang status ke sistem (memastikan berubah jadi 2)
      await checkSystemRoles();

      Get.snackbar(
        "Perlindungan Maksimal",
        "Cynix sekarang melindungi Telepon dan SMS Anda sepenuhnya.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on PlatformException catch (e) {
      Get.snackbar(
        "Dibatalkan",
        "Akses SMS belum diberikan.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // FUNGSI 3: MENGAMBIL DATA RIWAYAT SPAM
  // ============================================================
  Future<void> fetchBlockedLogs() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      callLogs.assignAll([
        CallLogModel(
          number: '+62 812-3456-7890',
          timestamp: DateTime.now().millisecondsSinceEpoch - 3600000,
        ),
        CallLogModel(
          number: '+62 815-9999-0000',
          timestamp: DateTime.now().millisecondsSinceEpoch - 86400000,
        ),
        CallLogModel(
          number: '+62 857-1111-2222',
          timestamp: DateTime.now().millisecondsSinceEpoch - 172800000,
        ),
      ]);
    } catch (e) {
      debugPrint("Error fetching logs: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class CallLogModel {
  final String number;
  final int timestamp;
  CallLogModel({required this.number, required this.timestamp});
}
