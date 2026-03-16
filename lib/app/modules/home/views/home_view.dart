import 'package:cynix/app/modules/Profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math' as math;
import '../controllers/home_controller.dart';
import '../../sms/views/sms_view.dart';
import '../../protection/views/protection_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Fungsi untuk mendapatkan sapaan berdasarkan waktu otomatis
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 19) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FA);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        // Dikembalikan ke light (putih) karena background atas kembali hitam
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,

        // ============================================================
        // BODY: MENGGUNAKAN HALAMAN ASLI
        // ============================================================
        body: Obx(
          () => IndexedStack(
            index: controller.tabIndex.value,
            children: [
              _buildHomeDashboard(context),
              const SmsView(),
              const ProtectionView(),
              const ProfileView(),
            ],
          ),
        ),

        // ============================================================
        // BOTTOM NAVIGATION BAR
        // ============================================================
        bottomNavigationBar: Obx(
          () => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.tabIndex.value,
              onTap: controller.changeTab,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF007AFF),
              unselectedItemColor: const Color(0xFFB0B0B0),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_rounded),
                  ),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.message_rounded),
                  ),
                  label: 'SMS',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.shield_rounded),
                  ),
                  label: 'Perlindungan',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_rounded),
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // KONTEN HALAMAN BERANDA UTAMA (CYNIX DASHBOARD)
  // ============================================================
  Widget _buildHomeDashboard(BuildContext context) {
    const headerColor = Color(0xFF0F172A); // Latar Belakang Hitam Navy (Asli)
    const cardColor = Colors.white;
    const textPrimary = Color(0xFF1E1E1E);
    const textGrey = Color(0xFF757575);

    // Mengambil nama pengguna dari Firestore/GetStorage
    final box = GetStorage();
    String userName = box.read('userName') ?? 'Pengguna Cynix';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // HEADER (SAPAAN + NAMA) & KARTU SIM
          // ============================================================
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: headerColor, // Tetap menggunakan warna gelap asli
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white, // Teks nama warna putih
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Kartu SIM berwarna putih di atas background hitam
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sim_card_rounded,
                          color: Color(0xFFE53935),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PROVIDER KARTU DI ATAS
                            Obx(
                              () => Text(
                                controller.simProvider.value,
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // NOMOR HP DI BAWAHNYA
                            Obx(
                              () => Text(
                                controller.simNumber.value,
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Aktif",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ============================================================
          // KARTU PERLINDUNGAN
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() {
              int level = controller.protectionLevel.value;
              String statusText = level == 0
                  ? "Rendah"
                  : level == 1
                  ? "Menengah"
                  : "Aman";
              Color statusColor = level == 0
                  ? const Color(0xFFE3434B)
                  : level == 1
                  ? const Color(0xFFFFB75E)
                  : const Color(0xFF4CAF50);
              String btnText = level == 0
                  ? 'Mulai Perlindungan'
                  : level == 1
                  ? 'Aktifkan Perlindungan SMS'
                  : 'Perlindungan Maksimal';

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perlindungan dan Keamanan',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 240,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            CustomPaint(
                              size: const Size(240, 120),
                              painter: GaugePainter(level),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'TINGKAT PERLINDUNGAN',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: level == 2
                            ? null
                            : () {
                                if (level == 0) {
                                  controller.activateSpamBlocking();
                                } else if (level == 1) {
                                  controller.activateSmsBlocking();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: level == 2
                              ? Colors.green
                              : const Color(0xFF007AFF),
                          disabledBackgroundColor: Colors.green.withOpacity(
                            0.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          btnText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // ============================================================
          // FITUR OSINT SERPAPI DORKING
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status OSINT Dorking',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isScanningLeaks.value) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF007AFF),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Melacak Google Dorking...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Memeriksa jejak nomor di Search Engine.",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.leakedSites.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.gpp_good_rounded,
                            color: Colors.green.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Aman! Tidak Ada Jejak Terbuka",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Pencarian Dorking tidak menemukan nomor Anda tersebar secara publik di internet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textGrey, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Ditemukan di ${controller.leakedSites.length} Halaman",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...controller.leakedSites
                            .map(
                              (leak) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.public,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leak.siteName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            leak.description,
                                            style: const TextStyle(
                                              color: textGrey,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: leak.severity == "Tinggi"
                                                  ? Colors.red
                                                  : Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Risiko ${leak.severity}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final int level;
  GaugePainter(this.level);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const strokeWidth = 18.0;
    Color activeColor = level == 0
        ? const Color(0xFFE3434B)
        : level == 1
        ? const Color(0xFFFFB75E)
        : const Color(0xFF4CAF50);
    final paintBg = Paint()
      ..color = const Color(0xFFEEF2F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final paintFg = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      180 * math.pi / 180,
      50 * math.pi / 180,
      false,
      paintFg,
    );
    canvas.drawArc(
      rect,
      240 * math.pi / 180,
      60 * math.pi / 180,
      false,
      level >= 1 ? paintFg : paintBg,
    );
    canvas.drawArc(
      rect,
      310 * math.pi / 180,
      50 * math.pi / 180,
      false,
      level >= 2 ? paintFg : paintBg,
    );
    double endAngle = level == 0
        ? 230.0
        : level == 1
        ? 300.0
        : 360.0;
    final dotCenter = Offset(
      center.dx + radius * math.cos(endAngle * math.pi / 180),
      center.dy + radius * math.sin(endAngle * math.pi / 180),
    );
    final paintDotBg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, strokeWidth * 0.75, paintDotBg);
    final paintDot = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, strokeWidth * 0.45, paintDot);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) =>
      oldDelegate.level != level;
}
