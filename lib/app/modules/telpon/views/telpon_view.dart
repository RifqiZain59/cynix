import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../controllers/telpon_controller.dart';

class TelponView extends GetView<TelponController> {
  const TelponView({super.key});

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Kontak Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchContacts(),
          ),
        ],
      ),
      body: Obx(() {
        // 1. Cek Loading
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: headerColor),
          );
        }

        // 2. Cek Jika List Kosong
        if (controller.contactsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.contact_page_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tidak ada kontak ditemukan.",
                  style: TextStyle(color: Color(0xFF757575), fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.fetchContacts(),
                  child: const Text("Coba Refresh"),
                ),
              ],
            ),
          );
        }

        // 3. Tampilkan List
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: controller.contactsList.length,
          itemBuilder: (context, index) {
            final contact = controller.contactsList[index];

            // Amankan Nama (displayName di flutter_contacts adalah String non-nullable)
            String name = contact.displayName.isEmpty
                ? "Tanpa Nama"
                : contact.displayName;

            // Amankan Inisial
            String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

            // Amankan Nomor Telepon
            String phoneNumber = "Tidak ada nomor";
            if (contact.phones.isNotEmpty) {
              phoneNumber = contact.phones.first.number;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF007AFF).withOpacity(0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    phoneNumber,
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.call, color: Colors.green, size: 20),
                    onPressed: () {
                      Get.snackbar(
                        "Panggilan",
                        "Memanggil $phoneNumber...",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
