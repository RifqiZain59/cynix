import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProtectionController extends GetxController {
  static const platform = MethodChannel('com.cynix.app/call_screening');

  var isLoading = false.obs;
  var callLogs = <CallLogModel>[].obs;

  // Filter untuk memisahkan tampilan "Semua Riwayat" dan "Hanya Terblokir"
  var currentFilter = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCallLogs(); // Panggil semua riwayat saat halaman dibuka
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
  }

  // Mengambil SEMUA riwayat (Masuk, Keluar, Missed, Blokir)
  Future<void> fetchAllCallLogs() async {
    isLoading.value = true;
    try {
      // Pastikan di Kotlin kamu membuat method 'getAllCallLogs'
      final List<dynamic> result = await platform.invokeMethod(
        'getAllCallLogs',
      );

      if (result.isNotEmpty) {
        callLogs.assignAll(
          result.map((data) {
            final map = Map<String, dynamic>.from(data as Map);
            return CallLogModel.fromMap(map);
          }).toList(),
        );
      } else {
        callLogs.clear();
      }
    } on PlatformException catch (e) {
      debugPrint("Gagal mengambil riwayat telepon: ${e.message}");
      callLogs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCallLogs() async {
    try {
      await platform.invokeMethod('clearCallLogs');
      callLogs.clear();
      Get.snackbar(
        "Dibersihkan",
        "Riwayat panggilan berhasil dihapus.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Gagal menghapus riwayat: $e");
    }
  }
}

// MODEL DATA: Menampung semua jenis panggilan
class CallLogModel {
  final String number;
  final String name; // Nama kontak jika ada
  final int timestamp;
  final String
  type; // 'INCOMING', 'OUTGOING', 'MISSED', 'BLOCKED_SYSTEM', 'BLOCKED_AI'

  CallLogModel({
    required this.number,
    required this.name,
    required this.timestamp,
    required this.type,
  });

  factory CallLogModel.fromMap(Map<String, dynamic> map) {
    return CallLogModel(
      number: map['number'] ?? 'Nomor Tidak Dikenal',
      name: map['name'] ?? '',
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      type: map['type'] ?? 'INCOMING',
    );
  }
}
