import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FA);
    const headerColor = Color(0xFF0F172A); // Biru Gelap Navy
    const cardColor = Colors.white;
    const textPrimary = Color(0xFF1E1E1E);
    const textGrey = Color(0xFF757575);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // HEADER ATAS (Biru Gelap Rata)
            // ============================================================
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 50,
              ),
              decoration: const BoxDecoration(color: headerColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Baris Judul & Premium Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Cynix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Search Bar (Kotak Abu-abu)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Pencarian berdasarkan nomor',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // 2 KOTAK (TELEPON & SMS) - Overlapping ke Header
            // ============================================================
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Kotak 1: TELEPON (Aktivasi)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.activateSpamBlocking(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.phone_in_talk_rounded,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Obx(
                                    () => Icon(
                                      Icons.check_circle,
                                      color:
                                          controller.protectionLevel.value >= 1
                                          ? Colors.green
                                          : Colors.grey.withOpacity(0.3),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Telepon',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(
                                () => Text(
                                  '${controller.callLogs.length} Spam diputus',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Kotak 2: SMS
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.activateSmsBlocking(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.message_rounded,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  Obx(
                                    () => Icon(
                                      Icons.check_circle,
                                      color:
                                          controller.protectionLevel.value >= 2
                                          ? Colors.green
                                          : Colors.grey.withOpacity(0.3),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'SMS',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(
                                () => Text(
                                  controller.protectionLevel.value >= 2
                                      ? 'Aktif'
                                      : 'Belum Aktif',
                                  style: TextStyle(
                                    color: controller.protectionLevel.value >= 2
                                        ? Colors.green
                                        : textGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // KARTU PERLINDUNGAN DINAMIS (Merah -> Kuning -> Hijau)
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(() {
                // Mengambil nilai level (0, 1, 2)
                int level = controller.protectionLevel.value;

                // Mengatur Teks dan Warna berdasarkan Level
                String statusText = level == 0
                    ? "Rendah"
                    : level == 1
                    ? "Menengah"
                    : "Aman";
                Color statusColor = level == 0
                    ? const Color(0xFFE3434B) // Merah
                    : level == 1
                    ? const Color(0xFFFFB75E) // Kuning/Orange
                    : const Color(0xFF4CAF50); // Hijau

                String descText = level == 0
                    ? 'Aktifkan perlindungan dari panggilan dan pesan\npenipuan.'
                    : level == 1
                    ? 'Satu langkah lagi! Aktifkan perlindungan SMS agar perangkat lebih aman.'
                    : 'Perangkat Anda terlindungi sepenuhnya dari Panggilan & SMS Spam.';

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

                      // Indikator Meteran Dinamis
                      Center(
                        child: SizedBox(
                          width: 240,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              CustomPaint(
                                size: const Size(240, 120),
                                painter: GaugePainter(
                                  level,
                                ), // Mengirimkan level ke painter
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
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor, // Warna teks dinamis
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
                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          descText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Aksi Dinamis
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: level == 2
                              ? null
                              : () {
                                  // Disable jika sudah Aman
                                  if (level == 0) {
                                    controller
                                        .activateSpamBlocking(); // Panggil Role Dialer Telepon
                                  } else if (level == 1) {
                                    controller
                                        .activateSmsBlocking(); // Panggil Role Dialer SMS
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
            // JUDUL RIWAYAT
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Pemblokiran',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: textGrey, size: 20),
                    onPressed: () => controller.fetchBlockedLogs(),
                  ),
                ],
              ),
            ),

            // ============================================================
            // LIST RIWAYAT SPAM
            // ============================================================
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                if (controller.callLogs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.grey,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada bot spam yang terdeteksi.',
                          style: TextStyle(color: textGrey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: controller.callLogs.length,
                  itemBuilder: (context, index) {
                    final log = controller.callLogs[index];

                    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
                      log.timestamp,
                    );
                    final String timeStr =
                        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                    final String dateStr = "${date.day}/${date.month}";

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.block_flipped,
                            color: Color(0xFFE53935),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          log.number,
                          style: const TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Diputus Otomatis oleh AI',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                color: textGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// KELAS TAMBAHAN: Meteran Dinamis (CustomPainter)
// ======================================================================
class GaugePainter extends CustomPainter {
  final int level; // 0 = Rendah, 1 = Menengah, 2 = Aman
  GaugePainter(this.level);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const strokeWidth = 18.0;

    // Warna Dinamis Berdasarkan Status Level
    Color activeColor = level == 0
        ? const Color(0xFFE3434B) // Merah
        : level == 1
        ? const Color(0xFFFFB75E) // Kuning
        : const Color(0xFF4CAF50); // Hijau

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

    // 1. Segmen Pertama (Pasti terisi / aktif)
    canvas.drawArc(
      rect,
      180 * math.pi / 180,
      50 * math.pi / 180,
      false,
      paintFg,
    );

    // 2. Segmen Kedua (Terisi jika level >= 1)
    canvas.drawArc(
      rect,
      240 * math.pi / 180,
      60 * math.pi / 180,
      false,
      level >= 1 ? paintFg : paintBg,
    );

    // 3. Segmen Ketiga (Terisi jika level >= 2)
    canvas.drawArc(
      rect,
      310 * math.pi / 180,
      50 * math.pi / 180,
      false,
      level >= 2 ? paintFg : paintBg,
    );

    // 4. Posisi Lingkaran Titik bergeser berdasarkan Level
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
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.level !=
        level; // Menggambar ulang HANYA ketika levelnya berubah
  }
}
