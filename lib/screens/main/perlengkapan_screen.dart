import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/perlengkapan_model.dart';
import '../../services/perlengkapan_service.dart';
import 'perlengkapan_detail_screen.dart';
import 'tambah_perlengkapan_screen.dart';
class PerlengkapanScreen extends StatefulWidget {
  const PerlengkapanScreen({super.key});

  @override
  State<PerlengkapanScreen> createState() => _PerlengkapanScreenState();
}

class _PerlengkapanScreenState extends State<PerlengkapanScreen> {
  late Future<List<PerlengkapanModel>> _futurePerlengkapan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futurePerlengkapan = PerlengkapanService.fetchPerlengkapan();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Perlengkapan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF5B913B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<PerlengkapanModel>>(
        future: _futurePerlengkapan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final List<PerlengkapanModel> data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('Belum ada data perlengkapan'));
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item.nama),
                    subtitle: Text('Tanggal: ${item.tanggal}'),
                    isThreeLine: true,
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPerlengkapanScreen(perlengkapan: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPerlengkapanScreen()),
          );
          if (result == true) {
            _refreshData();
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF5B913B),
      ),
    );
  }
}
