import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Suntik controller jika belum terdaftar (karena ProfileView dipanggil lewat BottomNav)
    final controller = Get.put(ProfileController());

    const primaryNavy = Color(0xFF0F172A);
    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => controller.fetchUserProfile(),
            tooltip: "Segarkan Data",
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: primaryNavy),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // ============================================================
              // HEADER PROFIL (FOTO, NAMA, EMAIL)
              // ============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 32, top: 24),
                decoration: const BoxDecoration(color: primaryNavy),
                child: Column(
                  children: [
                    // Lingkaran Foto Profil (Mengambil Inisial Nama)
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.userName.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.userEmail.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // MENU LIST (PENGATURAN)
              // ============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuCard(
                      icon: Icons.shield_rounded,
                      iconColor: Colors.green,
                      title: "Status Keamanan",
                      subtitle:
                          "Level Perlindungan: ${controller.protectionLevel.value == 2
                              ? 'Maksimal'
                              : controller.protectionLevel.value == 1
                              ? 'Menengah'
                              : 'Rendah'}",
                      onTap: () {
                        Get.snackbar(
                          "Info",
                          "Buka menu Perlindungan untuk mengubah status.",
                          backgroundColor: Colors.white,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF007AFF),
                      title: "Informasi Pribadi",
                      subtitle: "Ubah detail profil Anda",
                      onTap: () {
                        Get.snackbar(
                          "Info",
                          "Fitur ubah profil segera hadir.",
                          backgroundColor: Colors.white,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: Colors.orange,
                      title: "Kebijakan Privasi",
                      subtitle: "Ketentuan penggunaan data",
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // ============================================================
                    // TOMBOL KELUAR (LOGOUT)
                    // ============================================================
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => _showLogoutDialog(context, controller),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFE3434B),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFE3434B),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Keluar Akun",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE3434B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // WIDGET KARTU MENU (REUSABLE)
  // ============================================================
  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // POP-UP KONFIRMASI LOGOUT
  // ============================================================
  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Konfirmasi Keluar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun Cynix? Perlindungan panggilan mungkin akan terjeda.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              controller.logout(); // Jalankan fungsi logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3434B), // Merah
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
