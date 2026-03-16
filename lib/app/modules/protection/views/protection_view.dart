import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/protection_controller.dart';
import '../../home/controllers/home_controller.dart';

class ProtectionView extends StatelessWidget {
  const ProtectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final protectionController = Get.put(ProtectionController());
    final homeController = Get.find<HomeController>();

    const backgroundColor = Color(0xFFF5F7FA);
    const primaryNavy = Color(0xFF0F172A);
    const cardColor = Colors.white;
    const textPrimary = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Perlindungan Panggilan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        // ============================================================
        // CEK 1: APAKAH SUDAH JADI DEFAULT CALLER ID?
        // ============================================================
        if (homeController.protectionLevel.value < 1) {
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
                    "Aktifkan Perlindungan Panggilan untuk mengelola riwayat telepon dan memutus bot spam secara otomatis.",
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
                      onPressed: () => homeController.activateSpamBlocking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Mulai Perlindungan",
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
        // FILTER DATA (Memisahkan Semua vs Terblokir)
        // ============================================================
        final blockedCount = protectionController.callLogs
            .where((log) => log.type.contains('BLOCKED'))
            .length;
        final filteredLogs = protectionController.currentFilter.value == 'Semua'
            ? protectionController.callLogs
            : protectionController.callLogs
                  .where((log) => log.type.contains('BLOCKED'))
                  .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER NAVY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                bottom: 32,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(color: primaryNavy),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: Colors.greenAccent,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sistem Anti-Spam Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cynix mengelola riwayat telepon Anda dan menjadi tameng utama melawan bot spam.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // STATISTIK SINGKAT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.block,
                      iconColor: const Color(0xFFE3434B),
                      title: 'Total Diblokir',
                      value: blockedCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.phone_in_talk_rounded,
                      iconColor: const Color(0xFF007AFF),
                      title: 'Total Riwayat',
                      value: protectionController.callLogs.length.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ============================================================
            // TAB FILTER & JUDUL
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tab Toggle
                  Row(
                    children: [
                      _buildFilterChip('Semua', protectionController),
                      const SizedBox(width: 8),
                      _buildFilterChip('Terblokir', protectionController),
                    ],
                  ),
                  // Tombol Refresh/Hapus
                  InkWell(
                    onTap: () => protectionController.fetchAllCallLogs(),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ============================================================
            // DAFTAR RIWAYAT (Dinamic sesuai tab filter)
            // ============================================================
            Expanded(
              child: protectionController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : filteredLogs.isEmpty
                  ? const Center(
                      child: Text(
                        "Riwayat panggilan kosong.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          log.timestamp,
                        );
                        final dateStr =
                            "${date.day}/${date.month}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                        // Logika UI Berdasarkan Tipe Panggilan
                        Color iconColor;
                        IconData iconData;
                        String typeText;
                        Color bgColor;

                        switch (log.type) {
                          case 'INCOMING':
                            iconColor = Colors.green;
                            bgColor = Colors.green.withOpacity(0.1);
                            iconData = Icons.call_received_rounded;
                            typeText = "Masuk";
                            break;
                          case 'OUTGOING':
                            iconColor = Colors.blue;
                            bgColor = Colors.blue.withOpacity(0.1);
                            iconData = Icons.call_made_rounded;
                            typeText = "Keluar";
                            break;
                          case 'MISSED':
                            iconColor = Colors.redAccent;
                            bgColor = Colors.red.withOpacity(0.05);
                            iconData = Icons.call_missed_rounded;
                            typeText = "Tak Terjawab";
                            break;
                          case 'BLOCKED_SYSTEM':
                            iconColor = Colors.grey.shade700;
                            bgColor = Colors.grey.withOpacity(0.15);
                            iconData = Icons.block_rounded;
                            typeText = "Diblokir Sistem";
                            break;
                          case 'BLOCKED_AI':
                          default:
                            iconColor = const Color(0xFFE3434B);
                            bgColor = const Color(0xFFE3434B).withOpacity(0.1);
                            iconData = Icons.smart_toy_rounded;
                            typeText = "Diblokir AI";
                            break;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: log.type.contains('BLOCKED')
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData,
                                  color: iconColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.name.isNotEmpty
                                          ? log.name
                                          : log.number,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: log.type == 'MISSED'
                                            ? Colors.redAccent
                                            : textPrimary,
                                      ),
                                    ),
                                    if (log.name.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        log.number,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (log.type.contains('BLOCKED'))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    typeText,
                                    style: TextStyle(
                                      color: iconColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  // Widget untuk tombol filter (Semua / Terblokir)
  Widget _buildFilterChip(String label, ProtectionController controller) {
    return Obx(() {
      bool isSelected = controller.currentFilter.value == label;
      return GestureDetector(
        onTap: () => controller.setFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F172A)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
