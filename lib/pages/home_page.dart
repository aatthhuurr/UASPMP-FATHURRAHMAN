import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';
// impor form_page.dart yang nanti akan dibuat untuk tambah/edit data
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _ScrollConfiguration {}

class _HomePageState extends State<HomePage> {
  // 1. Variabel untuk menampung daftar transaksi di memori aplikasi
  List<Transaksi> _listTransaksi = [];

  // 2. Variabel penampung nilai 3 kartu ringkasan keuangan
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _sisaSaldo = 0;

  @override
  void initState() {
    super.initState();
    _muatDataDariDatabase(); // Otomatis mengambil data saat halaman pertama dibuka
  }

  // 3. Fungsi untuk mengambil data dari Hive dan menghitung isi 3 kartu besar
  void _muatDataDariDatabase() {
    // A. Ambil data mentah berbentuk Map dari Hive melalui DatabaseService
    final dataMentah = DatabaseService.ambilSemuaTransaksi();

    // B. Ubah data mentah tersebut menjadi List Objek Transaksi agar bisa dibaca Dart
    final List<Transaksi> dataTemporary = dataMentah.map((item) {
      return Transaksi.fromMap(item['id'], item);
    }).toList();

    // C. Reset hitungan kalkulator keuangan kita ke angka 0
    double pemasukan = 0;
    double pengeluaran = 0;

    // D. Sisir data satu per satu untuk menjumlahkan uang secara dinamis
    for (var trx in dataTemporary) {
      if (trx.jenis == 'Pemasukan') {
        pemasukan += trx.nominal;
      } else {
        pengeluaran += trx.nominal;
      }
    }

    // E. Perbarui tampilan layar (setState) agar angka di 3 kartu dan list berubah
    setState(() {
      _listTransaksi = dataTemporary;
      _totalPemasukan = pemasukan;
      _totalPengeluaran = pengeluaran;
      _sisaSaldo = pemasukan - pengeluaran; // Rumus sisa uang
    });
  }

  // 4. Fungsi untuk menampilkan konfirmasi sebelum menghapus data
  void _eksekusiHapus(String id) {
    // showDialog digunakan untuk memunculkan kotak pesan pop-up di layar
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus catatan keuangan ini?',
          ),
          actions: [
            // Pilihan 1: Tombol Batal
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                ); // Menutup kotak dialog tanpa melakukan apa-apa
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            // Pilihan 2: Tombol Hapus (Eksekusi)
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dulu kotak dialognya
                await DatabaseService.hapusTransaksi(
                  id,
                ); // Hapus data dari Hive
                _muatDataDariDatabase(); // Segarkan layar utama

                // Tampilkan notifikasi hitam kecil di bawah layar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan berhasil dihapus')),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Keuangan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ==================== BAGIAN ATAS: 3 KARTU RINGKASAN ====================
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // KARTU 1: Sisa Saldo Uang Utama (Paling Besar)
                Card(
                  color: Colors.teal.shade50,
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.teal,
                      size: 40,
                    ),
                    title: const Text(
                      'Sisa Uang (Saldo)',
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(_sisaSaldo)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Baris berisi 2 Kartu Berdampingan (Pemasukan & Pengeluaran)
                Row(
                  children: [
                    // KARTU 2: Total Pemasukan
                    Expanded(
                      child: Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pemasukan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(_totalPemasukan)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // KARTU 3: Total Pengeluaran
                    Expanded(
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pengeluaran',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(_totalPengeluaran)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pembatas visual teks riwayat
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Laporan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ==================== BAGIAN BAWAH: LIST VIEW RIWAYAT ====================
          Expanded(
            child: _listTransaksi.isEmpty
                ? const Center(child: Text('Belum ada catatan keuangan.'))
                : ListView.builder(
                    itemCount: _listTransaksi.length,
                    itemBuilder: (context, index) {
                      final transaksi = _listTransaksi[index];
                      final adakahPemasukan = transaksi.jenis == 'Pemasukan';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          // Simbol ikon panah masuk (hijau) atau panah keluar (merah)
                          leading: Icon(
                            adakahPemasukan
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: adakahPemasukan ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            transaksi.judul,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${transaksi.tanggal.day}-${transaksi.tanggal.month}-${transaksi.tanggal.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Agar row tidak memakan tempat mendatar
                            children: [
                              // Teks Jumlah Nominal Uang (+ atau -)
                              Text(
                                '${adakahPemasukan ? '+' : '-'} Rp ${NumberFormat('#,###', 'id_ID').format(transaksi.nominal)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: adakahPemasukan
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Tombol Aksi 1: EDIT DATA
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  // Navigasi ke FormPage sambil melempar data lama untuk diedit
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FormPage(transaksiLama: transaksi),
                                    ),
                                  );
                                  _muatDataDariDatabase(); // Segarkan layar setelah pulang dari halaman edit
                                },
                              ),

                              // Tombol Aksi 2: HAPUS DATA
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _eksekusiHapus(transaksi.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ==================== TOMBOL TAMBAH DATA (+) ====================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Navigasi ke FormPage kosongan untuk menambah data baru
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPage()),
          );
          _muatDataDariDatabase(); // Segarkan layar setelah pulang dari halaman input data baru
        },
      ),
    );
  }
}
