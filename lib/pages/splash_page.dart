import 'dart:async'; // Diimpor untuk menggunakan fungsi Timer (waktu jeda)
import 'package:flutter/material.dart';
// impor home_page.dart yang nanti akan kita buat di langkah berikutnya
import 'home_page.dart'; 

// wajib menggunakan StatefulWidget karena ada proses perubahan halaman otomatis menggunakan Timer
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    
    // 1. Mengatur durasi waktu Splash Screen muncul (kita set 3 detik)
    Timer(const Duration(seconds: 3), () {
      // 2. Navigator.pushReplacement digunakan untuk pindah ke halaman utama (HomePage)
      // pushReplacement dipakai agar ketika di halaman utama, 
      // pengguna tidak bisa klik tombol "kembali/back" ke halaman splash screen lagi.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Mengatur warna latar belakang halaman (kita pakai warna teal khas keuangan)
      backgroundColor: Colors.teal, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Membuat konten berada di tengah vertikal
          children: [
            // 3. Menampilkan Ikon Keuangan berukuran besar di tengah layar
            Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20), // Memberi jarak vertikal antar komponen
            
            // 4. Menampilkan Teks Judul Aplikasi
            Text(
              'Aplikasi Keuangan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            
            // 5. Animasi loading berputar kecil di bawah teks
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}