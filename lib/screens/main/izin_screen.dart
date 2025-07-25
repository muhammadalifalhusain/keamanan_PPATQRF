import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';
import 'tambah_izin_screen.dart';
class IzinScreen extends StatefulWidget {
  const IzinScreen({super.key});

  @override
  State<IzinScreen> createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
  late Future<List<Izin>> _izinList;

  @override
  void initState() {
    super.initState();
    _izinList = IzinService.fetchIzin();
  }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Izin',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<Izin>>(
        future: _izinList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data izin: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data izin',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final izinList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: izinList.length,
            itemBuilder: (context, index) {
              final izin = izinList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    izin.nama,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: ${izin.tanggal}'),
                        Text('Jam Keluar: ${izin.keluar}'),
                        Text('Jam Kembali: ${izin.kembali}'),
                        Text('Kategori: ${izin.kategori}'),
                        Text('Status: ${izin.status}'),
                        Text('Pelanggaran: ${izin.kategoriPelanggaran}'),
                        if (izin.namaPengisi != '-') Text('Pengisi: ${izin.namaPengisi}'),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () async {
                          // Navigasi ke halaman edit dengan data izin
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahIzinScreen(izin: izin), 
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _izinList = IzinService.fetchIzin();
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text('Yakin ingin menghapus data ini?'),
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
                            final success = await IzinService.deleteIzin(izin.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Data berhasil dihapus')),
                              );
                              setState(() {
                                _izinList = IzinService.fetchIzin();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gagal menghapus data')),
                              );
                            }
                          }
                        },
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
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TambahIzinScreen(),
              ),
            );
            if (result == true) {
              setState(() {
                _izinList = IzinService.fetchIzin(); // atau panggil _refreshData jika ada
              });
            }
          },
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Tambah',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

    );
  }
}