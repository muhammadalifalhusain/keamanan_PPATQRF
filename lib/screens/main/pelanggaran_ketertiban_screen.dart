import 'package:flutter/material.dart';
import '../../models/pelanggaran_ketertiban_model.dart';
import '../../services/pelanggaran_ketertiban_service.dart';
import 'tambah_pelanggaran_ketertiban_screen.dart';

import 'package:google_fonts/google_fonts.dart';
class PelanggaranKetertibanScreen extends StatefulWidget {
  const PelanggaranKetertibanScreen({super.key});

  @override
  State<PelanggaranKetertibanScreen> createState() => _PelanggaranKetertibanScreenState();
}

class _PelanggaranKetertibanScreenState extends State<PelanggaranKetertibanScreen> {
  late Future<List<PelanggaranKetertiban>> _pelanggaranFuture;

  @override
  void initState() {
    super.initState();
    _pelanggaranFuture = PelanggaranKetertibanService.fetchAll();
  }

  void _refresh() {
    setState(() {
      _pelanggaranFuture = PelanggaranKetertibanService.fetchAll();
    });
  }

  void _hapus(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await PelanggaranKetertibanService.delete(id);
      _refresh();
    }
  }

  void _navigateToForm({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPelanggaranKetertibanScreen(idEdit: id),
      ),
    );
    _refresh();
  }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white, // mengatur teks dan ikon jadi putih
        title: const Text(
          'Pelanggaran Ketertiban',
          style: TextStyle(color: Colors.white), // tambahan jika perlu
        ),
      ),
      body: FutureBuilder<List<PelanggaranKetertiban>>(
        future: _pelanggaranFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                child: ListTile(
                  title: Text('${item.nama}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal: ${item.tanggal}'),
                      Text('Buang Sampah: ${item.buangSampah}, Menata: ${item.menataPeralatan}, Tidak Berseragam: ${item.tidakBerseragam}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(id: item.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapus(item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToForm(),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Tambah',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
    );
  }
}