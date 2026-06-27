import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/database_service.dart';

class FormPage extends StatefulWidget {
  // Variabel opsional untuk menerima data lama jika dalam mode EDIT DATA
  final Transaksi? transaksiLama;

  const FormPage({super.key, this.transaksiLama});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // 1. Kunci pengontrol validasi form input
  final _formKey = GlobalKey<FormState>();

  // 2. Controller untuk menangkap teks yang diketik pengguna
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();

  // 3. Variabel untuk menyimpan pilihan Dropdown jenis transaksi (Default: Pengeluaran)
  String _jenisTerpilih = 'Pengeluaran';

  // 4. Variabel penanda apakah ini mode Edit atau mode Tambah Baru
  bool _apakahModeEdit = false;

  @override
  void initState() {
    super.initState();

    // Mengecek apakah ada data lama yang dikirim ke halaman ini
    if (widget.transaksiLama != null) {
      _apakahModeEdit = true;
      // Jika mode edit, langsung isi kotak input dengan data lama tersebut
      _judulController.text = widget.transaksiLama!.judul;
      _nominalController.text = widget.transaksiLama!.nominal.toStringAsFixed(
        0,
      );
      _jenisTerpilih = widget.transaksiLama!.jenis;
    }
  }

  // 5. Fungsi utama untuk menyimpan data ke Hive saat tombol klik ditekan
  void _simpanData() async {
    // Jalankan validasi. Jika ada kotak yang kosong, batalkan proses simpan
    if (!_formKey.currentState!.validate()) return;

    // Membungkus data dari kotak input ke dalam format Map standar Hive
    final Map<String, dynamic> dataTransaksi = {
      'judul': _judulController.text,
      'nominal': double.parse(_nominalController.text),
      'jenis': _jenisTerpilih,
      'tanggal': _apakahModeEdit
          ? widget.transaksiLama!.tanggal
                .toIso8601String() // Tetapkan tanggal lama jika edit
          : DateTime.now()
                .toIso8601String(), // Gunakan tanggal baru jika tambah
    };

    if (_apakahModeEdit) {
      // Jalankan fungsi UPDATE jika dalam mode edit
      await DatabaseService.ubahTransaksi(
        widget.transaksiLama!.id,
        dataTransaksi,
      );

      // TAMPILKAN NOTIFIKASI EDIT SUKSES
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui!')),
        );
      }
    } else {
      // Jalankan fungsi CREATE jika dalam mode tambah baru
      await DatabaseService.tambahTransaksi(dataTransaksi);

      // TAMPILKAN NOTIFIKASI TAMBAH SUKSES
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan!')),
        );
      }
    }

    // Kembali ke halaman utama setelah berhasil menyimpan data
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul AppBar berubah dinamis menyesuaikan mode aplikasi
        title: Text(
          _apakahModeEdit ? 'Edit Catatan' : 'Tambah Catatan',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Menggunakan widget Form untuk mengaktifkan fitur validasi input
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // INPUT 1: Judul Catatan Keuangan
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Nama Catatan (Judul)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
                // Validasi: memastikan kolom ini tidak boleh kosong saat disimpan
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // INPUT 2: Nominal Uang (Angka)
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType
                    .number, // Menampilkan keyboard khusus angka saja
                decoration: const InputDecoration(
                  labelText: 'Nominal Uang (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal uang tidak boleh kosong!';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harus diisi dengan angka yang valid!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // INPUT 3: Pilihan Jenis (Pemasukan / Pengeluaran) menggunakan Dropdown
              DropdownButtonFormField<String>(
                value: _jenisTerpilih,
                decoration: const InputDecoration(
                  labelText: 'Jenis Transaksi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                // Daftar pilihan dropdown
                items: const [
                  DropdownMenuItem(
                    value: 'Pemasukan',
                    child: Text('Pemasukan (Uang Masuk)'),
                  ),
                  DropdownMenuItem(
                    value: 'Pengeluaran',
                    child: Text('Pengeluaran (Uang Keluar)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _jenisTerpilih = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // TOMBOL EKSEKUSI SIMPAN
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _apakahModeEdit ? 'Perbarui Data' : 'Simpan Data',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
