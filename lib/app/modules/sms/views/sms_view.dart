import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sms_controller.dart';
import '../../home/controllers/home_controller.dart'; // Import HomeController untuk cek role

// Ubah GetView menjadi StatelessWidget biasa
class SmsView extends StatelessWidget {
  const SmsView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. SOLUSI ERROR: Suntikkan SmsController secara manual di sini
    final controller = Get.put(SmsController());

    // 2. Ambil HomeController untuk mengecek apakah sudah jadi Default SMS
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // Biru Gelap Navy
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Pesan Masuk (AI Scan)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Tombol refresh hanya aktif kalau sudah jadi default SMS
          Obx(() {
            if (homeController.protectionLevel.value >= 2) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => controller.fetchAndScanRealSms(),
              );
            }
            return const SizedBox.shrink(); // Sembunyikan jika belum default
          }),
        ],
      ),
      body: Obx(() {
        // ============================================================
        // CEK 1: APAKAH SUDAH JADI DEFAULT SMS? (Level 2)
        // ============================================================
        if (homeController.protectionLevel.value < 2) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 64,
                      color: Color(0xFFE3434B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Fitur Terkunci",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Jadikan Cynix sebagai aplikasi Default SMS Anda untuk memindai pesan dari penipuan, Pinjol, atau Judol secara otomatis dengan AI.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // Memanggil fungsi dari HomeController untuk meminta izin SMS
                      onPressed: () => homeController.activateSmsBlocking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Jadikan Default SMS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ============================================================
        // CEK 2: JIKA SUDAH DEFAULT, APAKAH SEDANG LOADING?
        // ============================================================
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0F172A)),
          );
        }

        // ============================================================
        // CEK 3: JIKA KOSONG
        // ============================================================
        if (controller.messages.isEmpty) {
          return const Center(child: Text("Belum ada pesan masuk di HP Anda."));
        }

        // ============================================================
        // TAMPILAN UTAMA: DAFTAR SMS
        // ============================================================
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final scannedData = controller.messages[index];
            final sms = scannedData.originalSms;

            // Format waktu pengiriman SMS
            final date = sms.date ?? DateTime.now();
            final dateStr =
                "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

            // Konfigurasi Warna & Ikon berdasarkan Kategori Scan AI
            Color badgeColor;
            IconData badgeIcon;

            switch (scannedData.category) {
              case 'JUDOL':
              case 'SPAM PENIPUAN':
                badgeColor = const Color(0xFFE3434B); // Merah Bahaya
                badgeIcon = Icons.warning_rounded;
                break;
              case 'PINJOL':
                badgeColor = const Color(0xFFFFB75E); // Orange Peringatan
                badgeIcon = Icons.money_off;
                break;
              case 'OTP':
                badgeColor = const Color(0xFF007AFF); // Biru Informasi
                badgeIcon = Icons.vpn_key_rounded;
                break;
              default:
                badgeColor = const Color(0xFF4CAF50); // Hijau Aman
                badgeIcon = Icons.check_circle;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: badgeColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pengirim SMS
                      Expanded(
                        child: Text(
                          sms.address ?? "Nomor Tidak Diketahui",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge Kategori Scan
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, color: badgeColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              scannedData.category,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Teks SMS Asli
                  Text(
                    sms.body ?? "",
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tanggal & Waktu SMS
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
