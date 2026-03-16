import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model data internal untuk menampung riwayat blokir
class CustomCallLog {
  final String number;
  final int timestamp;
  CustomCallLog({required this.number, required this.timestamp});
}

class HomeController extends GetxController {
  final callLogs = <CustomCallLog>[].obs;
  final isLoading = false.obs;
  static const platform = MethodChannel('com.cynix.app/call_screening');

  @override
  void onInit() {
    super.onInit();
    fetchBlockedLogs();
  }

  /// Meminta sistem Android menjadikan Cynix sebagai Default Spam App
  Future<void> activateSpamBlocking() async {
    try {
      final String result = await platform.invokeMethod('requestRole');
      print(result);
    } on PlatformException catch (e) {
      print("Gagal mengaktifkan role: ${e.message}");
    }
  }

  /// Mengambil data dari penyimpanan internal aplikasi (yang disimpan oleh Kotlin)
  Future<void> fetchBlockedLogs() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? rawData = prefs.getString('blocked_list');

      if (rawData != null && rawData.isNotEmpty) {
        List<String> entries = rawData.split(';');
        List<CustomCallLog> tempLogs = [];

        for (var entry in entries) {
          if (entry.contains('|')) {
            List<String> parts = entry.split('|');
            tempLogs.add(
              CustomCallLog(number: parts[0], timestamp: int.parse(parts[1])),
            );
          }
        }
        callLogs.assignAll(tempLogs);
      }
    } catch (e) {
      print("Gagal mengambil log: $e");
    }
    isLoading.value = false;
  }
}
