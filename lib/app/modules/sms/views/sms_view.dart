import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sms_controller.dart';

class SmsView extends GetView<SmsController> {
  const SmsView({super.key});

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchAndScanRealSms(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0F172A)),
          );
        }

        if (controller.messages.isEmpty) {
          return const Center(child: Text("Belum ada pesan masuk di HP Anda."));
        }

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
