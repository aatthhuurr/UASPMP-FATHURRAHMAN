// impor package Hive dari pubspec.yaml
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  // 1. Nama kotak/tabel penyimpanan database di dalam Hive
  static const String _boxName = 'box_keuangan';

  // 2. Fungsi untuk MEMBUKA database
  //dipanggil sekali saja di main.dart saat aplikasi pertama kali start
  static Future<void> initDatabase() async {
    await Hive.initFlutter(); // Menyiapkan sistem database Hive di laptop/HP
    await Hive.openBox(
      _boxName,
    ); // Membuka kotak penyimpanan bernama 'box_keuangan'
  }

  // 3. Fungsi TAMBAH DATA (Create)
  // Dipakai saat pengguna menekan tombol simpan transaksi baru
  static Future<void> tambahTransaksi(Map<String, dynamic> dataBaru) async {
    var box = Hive.box(_boxName);
    await box.add(dataBaru); // Memasukkan Map data baru ke dalam database Hive
  }

  // 4. Fungsi AMBIL SEMUA DATA (Read)
  // Dipakai untuk menampilkan semua riwayat di halaman utama
  static List<Map<dynamic, dynamic>> ambilSemuaTransaksi() {
    var box = Hive.box(_boxName);
    List<Map<dynamic, dynamic>> listData = [];

    // Menyisir seluruh data di dalam database satu per satu
    for (var key in box.keys) {
      var data = box.get(key);
      if (data != null) {
        // Kita selipkan kunci/ID asli dari Hive ke dalam data
        // penting supaya tahu data mana yang mau diedit atau dihapus nanti
        data['id'] = key.toString();
        listData.add(data);
      }
    }
    return listData;
  }

  // 5. Fungsi UBAH DATA (Update)
  // Dipakai saat pengguna mengedit transaksi yang sudah ada
  static Future<void> ubahTransaksi(
    String id,
    Map<String, dynamic> dataBaru,
  ) async {
    var box = Hive.box(_boxName);
    // Mengubah data lama berdasarkan nomor ID (key) yang dikirim
    await box.put(int.parse(id), dataBaru);
  }

  // 6. Fungsi HAPUS DATA (Delete)
  // Dipakai saat pengguna menekan ikon tempat sampah di riwayat
  static Future<void> hapusTransaksi(String id) async {
    var box = Hive.box(_boxName);
    // Menghapus data dari database berdasarkan ID uniknya
    await box.delete(int.parse(id));
  }
}
