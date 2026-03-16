import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class TelponController extends GetxController {
  var contactsList = <Contact>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    isLoading.value = true;
    debugPrint("DEBUG: Memulai proses pengambilan kontak...");

    try {
      // PERBAIKAN: Langsung panggil tanpa .config
      bool allowed = await FlutterContacts.requestPermission();

      if (allowed) {
        debugPrint("DEBUG: Izin DIBERIKAN oleh sistem Android.");

        // Ambil kontak dengan properti lengkap (nomor telepon, dll)
        // Kita matikan foto (withPhoto: false) agar proses loading lebih ringan dan cepat
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        debugPrint(
          "DEBUG: Berhasil menarik data. Jumlah: ${contacts.length} kontak.",
        );
        contactsList.assignAll(contacts);
      } else {
        debugPrint("DEBUG: Izin DITOLAK oleh sistem atau user.");
        Get.snackbar(
          "Akses Ditolak",
          "Aplikasi tidak diizinkan membaca kontak. Silakan cek pengaturan HP.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("DEBUG: Terjadi Error Sistem: $e");
      Get.snackbar("Error", "Gagal mengambil data kontak: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
