import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'pages/splash_page.dart';

void main() async {
  // 1. Memastikan semua sistem internal Flutter siap dijalankan
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Menyalakan database Hive sebelum aplikasi menampilkan layar
  // Ini fungsi async-await agar aplikasi menunggu database siap dulu
  await DatabaseService.initDatabase();

  // 3. Menjalankan aplikasi utama
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Menghilangkan tanda pita merah "DEBUG" di pojok kanan atas biar tampilan rapi
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Keuangan UAS',
      // Mengatur tema warna dasar aplikasi (pakai warna hijau/teal khas keuangan)
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3:
            true, // Menggunakan desain Material 3 yang modern dan rapi
      ),
      // Halaman pertama yang otomatis dibuka saat aplikasi start adalah SplashPage
      home: const SplashPage(),
    );
  }
}
