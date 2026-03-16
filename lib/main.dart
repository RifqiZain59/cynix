import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'firebase_options.dart'; // Import file konfigurasi Firebase
import 'app/routes/app_pages.dart';

void main() async {
  // 1. Pastikan binding Flutter sudah siap (Wajib untuk Firebase & GetStorage)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Inisialisasi GetStorage
  await GetStorage.init();

  // 4. Cek Status Login dari Memori Lokal
  final box = GetStorage();
  bool isLoggedIn = box.read('isLoggedIn') ?? false;

  runApp(
    GetMaterialApp(
      title: "Cynix",
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      // Jika isLoggedIn true -> Buka HOME. Jika false -> Buka halaman awal
      initialRoute: isLoggedIn ? Routes.HOME : AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
