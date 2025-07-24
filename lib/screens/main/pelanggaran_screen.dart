import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pelanggaran_service.dart';
import '../../models/pelanggaran_model.dart';
import 'tambah_pelanggaran_screen.dart';

class PelanggaranScreen extends StatefulWidget {
  const PelanggaranScreen({super.key});

  @override
  State<PelanggaranScreen> createState() => _PelanggaranScreenState();
}

class _PelanggaranScreenState extends State<PelanggaranScreen> {
  late Future<List<Pelanggaran>> _pelanggaranList;

  @override
  void initState() {
    super.initState();
    _loadPelanggaran();
  }

  void _loadPelanggaran() {
    setState(() {
      _pelanggaranList = PelanggaranService.fetchPelanggaran();
    });
  }

  void _deletePelanggaran(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PelanggaranService.deletePelanggaran(int.parse(id));
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menghapus data')),
        );
        _loadPelanggaran(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF263238),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pelanggaran',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<Pelanggaran>>(
        future: _pelanggaranList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data pelanggaran.',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    item.nama,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Tanggal: ${item.tanggal}', style: GoogleFonts.poppins()),
                      Text('Jenis: ${item.jenisPelanggaran}', style: GoogleFonts.poppins()),
                      Text('Kategori: ${item.kategori}', style: GoogleFonts.poppins()),
                      Text('Hukuman: ${item.hukuman}', style: GoogleFonts.poppins()),
                      Text('Pengisi: ${item.namaPengisi}', style: GoogleFonts.poppins()),
                    ],
                  ),
                  leading: const Icon(Icons.warning_amber, color: Colors.orange),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          // Navigasi ke form edit, lalu refresh setelah kembali
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostPelanggaranScreen(
                                pelanggaran: item,
                              ),
                            ),
                          );
                          _loadPelanggaran(); 
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePelanggaran(item.id.toString()),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostPelanggaranScreen()),
          );
          _loadPelanggaran(); // Refresh setelah tambah
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Pelanggaran',
      ),
    );
  }
}
