import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

// Struktur Data SMS Hasil Scan Internal
class ScannedSms {
  final SmsMessage originalSms;
  final String category;

  ScannedSms({required this.originalSms, required this.category});
}

class SmsController extends GetxController {
  final SmsQuery _query = SmsQuery();
  var messages = <ScannedSms>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAndScanRealSms();
  }

  // ==========================================================
  // FUNGSI MENGAMBIL DAN SCAN SMS ASLI DARI HP
  // ==========================================================
  Future<void> fetchAndScanRealSms() async {
    isLoading.value = true;

    // 1. Minta izin baca SMS dengan cara yang lebih ketat
    PermissionStatus status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }

    if (status.isGranted) {
      try {
        // 2. PERBAIKAN: Ambil SMS tanpa parameter 'count' agar tidak crash di HP tertentu
        List<SmsMessage> inboxData = await _query.querySms(
          kinds: [SmsQueryKind.inbox],
        );

        // 3. Potong datanya manual di Dart agar aplikasi tetap ringan (maksimal 100 pesan terbaru)
        if (inboxData.length > 100) {
          inboxData = inboxData.sublist(0, 100);
        }

        List<ScannedSms> scannedList = [];
        for (var sms in inboxData) {
          // Scanner membaca teks (jika null, dianggap kosong)
          String category = checkSmsCategory(sms.body ?? "");
          scannedList.add(ScannedSms(originalSms: sms, category: category));
        }

        messages.assignAll(scannedList);
      } catch (e) {
        debugPrint("Gagal mengambil SMS: $e");
        // Memunculkan pesan error spesifik jika masih gagal
        Get.snackbar(
          "Gagal Membaca SMS",
          "Terjadi kesalahan sistem: $e",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } else {
      Get.snackbar(
        "Akses Ditolak",
        "Cynix butuh izin SMS. Silakan izinkan di Pengaturan HP Anda.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  // ==========================================================
  // MESIN SCANNER (Deteksi Kata Kunci)
  // ==========================================================
  String checkSmsCategory(String text) {
    String lowerText = text.toLowerCase();

    if (lowerText.contains('otp') ||
        lowerText.contains('kode verifikasi') ||
        lowerText.contains('sandi rahasia')) {
      return 'OTP';
    } else if (lowerText.contains('slot') ||
        lowerText.contains('gacor') ||
        lowerText.contains('maxwin') ||
        lowerText.contains('zeus') ||
        lowerText.contains('depo')) {
      return 'JUDOL';
    } else if (lowerText.contains('pinjaman') ||
        lowerText.contains('dana tunai') ||
        lowerText.contains('tanpa agunan') ||
        lowerText.contains('cair cepat') ||
        lowerText.contains('kredit')) {
      return 'PINJOL';
    } else if ((lowerText.contains('selamat') &&
            lowerText.contains('menang')) ||
        lowerText.contains('hadiah') ||
        lowerText.contains('klaim') ||
        lowerText.contains('undian')) {
      return 'SPAM PENIPUAN';
    } else {
      return 'AMAN';
    }
  }
}
