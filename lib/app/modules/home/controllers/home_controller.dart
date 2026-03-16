import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeController extends GetxController {
  static const platform = MethodChannel('com.cynix.app/call_screening');

  var isLoading = false.obs;
  var callLogs = <CallLogModel>[].obs;
  var protectionLevel = 0.obs;

  var simProvider = "Memeriksa SIM...".obs;
  var simNumber = "Memeriksa Nomor...".obs;

  var isScanningLeaks = false.obs;
  var leakedSites = <LeakModel>[].obs;

  // Variabel pengatur indeks Bottom Navigation Bar
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedLogs();
    checkSystemRoles();
    fetchSimInfo();
  }

  // Mengubah tab di Bottom Navigation Bar (tanpa Get.toNamed agar menu bawah tetap ada)
  void changeTab(int index) {
    tabIndex.value = index;
  }

  Future<void> fetchSimInfo() async {
    try {
      if (await Permission.phone.request().isGranted) {
        final Map<dynamic, dynamic> result = await platform.invokeMethod(
          'getSimInfo',
        );
        simProvider.value = result['carrierName'] ?? "Tidak Diketahui";
        simNumber.value = result['phoneNumber'] ?? "Tidak Tersedia di SIM";

        if (simNumber.value != "Tidak Tersedia di SIM" &&
            simNumber.value.isNotEmpty) {
          autoScanLeaks();
        }
      } else {
        simProvider.value = "Akses Ditolak";
        simNumber.value = "Izin Telepon Diperlukan";
      }
    } on PlatformException catch (e) {
      simProvider.value = "Error SIM";
      simNumber.value = "Error Baca Nomor";
    }
  }

  Future<void> checkSystemRoles() async {
    try {
      final int level = await platform.invokeMethod('checkRoles');
      protectionLevel.value = level;
    } on PlatformException catch (e) {
      debugPrint("Gagal mengecek role sistem: ${e.message}");
    }
  }

  Future<void> activateSpamBlocking() async {
    try {
      await platform.invokeMethod('requestRole');
      await checkSystemRoles();
    } catch (e) {
      debugPrint("Batal Telepon");
    }
  }

  Future<void> activateSmsBlocking() async {
    try {
      await platform.invokeMethod('requestSmsRole');
      await checkSystemRoles();
    } catch (e) {
      debugPrint("Batal SMS");
    }
  }

  // ============================================================
  // FUNGSI SCAN KEBOCORAN (MENGGUNAKAN SERPAPI - GOOGLE SEARCH)
  // ============================================================
  Future<void> autoScanLeaks() async {
    isScanningLeaks.value = true;
    leakedSites.clear();

    String pureNumber = simNumber.value.replaceAll(RegExp(r'\s+|-|\+'), '');

    if (pureNumber.isEmpty || pureNumber.length < 5) {
      isScanningLeaks.value = false;
      return;
    }

    const String SERP_API_KEY =
        "0be071881c87efdd177cb2f9231fa99c9a97932e50dc6ba77a3445479c2259bc";

    try {
      String query = '"$pureNumber"';
      final url = Uri.parse(
        'https://serpapi.com/search.json?q=${Uri.encodeComponent(query)}&api_key=$SERP_API_KEY&engine=google',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['organic_results'] != null) {
          List<dynamic> results = data['organic_results'];
          List<LeakModel> leaks = [];

          for (var item in results) {
            String link = item['link'] ?? '';
            String snippet = item['snippet'] ?? 'Deskripsi tidak tersedia';
            String domain = "Situs Tidak Diketahui";

            try {
              domain = Uri.parse(link).host.replaceFirst('www.', '');
            } catch (e) {}

            String severity = "Menengah";
            String linkLower = link.toLowerCase();
            if (linkLower.contains('pastebin') ||
                linkLower.contains('leak') ||
                linkLower.contains('breach') ||
                linkLower.contains('hacker') ||
                linkLower.contains('forum')) {
              severity = "Tinggi";
            }

            leaks.add(
              LeakModel(
                siteName: domain,
                description: snippet,
                severity: severity,
              ),
            );
          }
          leakedSites.assignAll(leaks);
        }
      } else {
        debugPrint("SerpApi Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error SerpApi: $e");
    } finally {
      isScanningLeaks.value = false;
    }
  }

  Future<void> fetchBlockedLogs() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      callLogs.clear();
    } catch (e) {
      debugPrint("Error: $e");
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

class LeakModel {
  final String siteName;
  final String description;
  final String severity;
  LeakModel({
    required this.siteName,
    required this.description,
    required this.severity,
  });
}
