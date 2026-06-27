// Ini adalah kelas cetakan untuk data transaksi keuangan
class Transaksi {
  // 1. Variabel untuk menyimpan data (apa saja isi dari satu catatan keuangan)
  final String id; // ID unik untuk membedakan antar data agar tidak tertukar
  final String judul; // Nama catatan (contoh: "Bayar Kosan" atau "Uang Jajan")
  final double nominal; // Jumlah uangnya (menggunakan angka)
  final String jenis; // Jenisnya, apakah "Pemasukan" atau "Pengeluaran"
  final DateTime tanggal; // Waktu kapan catatan ini dibuat

  // 2. Constructor: Fungsi untuk membuat data transaksi baru
  Transaksi({
    required this.id,
    required this.judul,
    required this.nominal,
    required this.jenis,
    required this.tanggal,
  });

  // 3. Fungsi mengubah dari format Map (Database Hive) menjadi Objek Dart yaitu
  //mengambil data lama dari Hive untuk ditampilkan di layar
  factory Transaksi.fromMap(String keyId, Map<dynamic, dynamic> map) {
    return Transaksi(
      id: keyId,
      judul: map['judul'] ?? '',
      nominal: (map['nominal'] ?? 0).toDouble(),
      jenis: map['jenis'] ?? 'Pengeluaran',
      tanggal: DateTime.parse(
        map['tanggal'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // 4. Fungsi mengubah dari Objek Dart menjadi format Map
  // yaitu saat mau menyimpan data baru ke dalam database Hive
  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'nominal': nominal,
      'jenis': jenis,
      'tanggal': tanggal
          .toIso8601String(), // Mengubah tanggal jadi teks biasa agar Hive bisa simpan
    };
  }
}
