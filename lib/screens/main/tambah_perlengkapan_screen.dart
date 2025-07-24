import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/perlengkapan_model.dart';
import '../../services/perlengkapan_service.dart';
import '../../models/santri_model.dart';
import '../../services/santri_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/session_manager.dart';
class TambahPerlengkapanScreen extends StatefulWidget {
  const TambahPerlengkapanScreen({super.key});

  @override
  State<TambahPerlengkapanScreen> createState() => _TambahPerlengkapanScreenState();
}

class _TambahPerlengkapanScreenState extends State<TambahPerlengkapanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _namaPengisiController = TextEditingController();
  final String _tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  List<Santri> santriList = [];
  Santri? selectedSantri;
  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      setState(() {
        santriList = response.data;
      });
    } catch (_) {}
  }
  final Map<String, int> _items = {
    "buku": 0,
    "bukuLayak": 0,
    "pensil": 0,
    "pensilLayak": 0,
    "bolpoin": 0,
    "bolpoinLayak": 0,
    "penghapus": 0,
    "penghapusLayak": 0,
    "penyerut": 0,
    "penyerutLayak": 0,
    "penggaris": 0,
    "penggarisLayak": 0,
    "boxPensil": 0,
    "boxPensilLayak": 0,
    "putih": 0,
    "putihLayak": 0,
    "batik": 0,
    "batikLayak": 0,
    "coklat": 0,
    "coklatLayak": 0,
    "kerudung": 0,
    "kerudungLayak": 0,
    "peci": 0,
    "peciLayak": 0,
    "kaosKaki": 0,
    "kaosKakiLayak": 0,
    "sepatu": 0,
    "sepatuLayak": 0,
    "ikatPinggang": 0,
    "ikatPinggangLayak": 0,
    "mukenah": 0,
    "mukenahLayak": 0,
    "alQuran": 0,
    "alQuranLayak": 0,
    "jubahPpatq": 0,
    "jubahPpatqLayak": 0,
    "bajuHijauStel": 0,
    "bajuHijauStelLayak": 0,
    "bajuUnguStel": 0,
    "bajuUnguStelLayak": 0,
    "bajuMerahStel": 0,
    "bajuMerahStelLayak": 0,
    "kaosHijauStel": 0,
    "kaosMerahStelLayak": 0,
    "kaosUnguStel": 0,
    "kaosUnguStelLayak": 0,
    "kaosKuningStel": 0,
    "kaosKuningStelLayak": 0,
    "sabun": 0,
    "sabunLayak": 0,
    "shampo": 0,
    "shampoLayak": 0,
    "sikat": 0,
    "sikatLayak": 0,
    "pastaGigi": 0,
    "pastaGigiLayak": 0,
    "kotakSabun": 0,
    "kotakSabunLayak": 0,
    "handuk": 0,
    "handukLayak": 0,
    "kasur": 0,
    "kasurLayak": 0,
    "bantal": 0,
    "bantalLayak": 0,
    "guling": 0,
    "gulingLayak": 0,
    "sarungBantal": 0,
    "sarungBantalLayak": 0,
    "sarungGuling": 0,
    "sarungGulingLayak": 0,
    "sandal": 0,
    "sandalLayak": 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchSantri();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedSantri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Santri dan kategori wajib diisi')),
        );
        return;
      }

      final idPengisi = await SessionManager.getid();

      if (idPengisi == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session habis. Silakan login ulang.")),
        );
        return;
      }

      final request = PostPerlengkapanRequest(
        noInduk: selectedSantri!.noInduk,
        tanggal: _tanggal,
        items: _items.map((k, v) => MapEntry(k, v.toString())),
        keterangan: _keteranganController.text,
        namaPengisi: idPengisi.toString(),
      );

      try {
        final success = await PerlengkapanService.postPerlengkapan(request.toJson());
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil disimpan')),
          );
          Navigator.pop(context, true); // Kirim true ke halaman sebelumnya
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }


  Widget _buildItemSwitch(String key) {
    return SwitchListTile(
      title: Text(key),
      subtitle: Text(_items[key] == 0 ? 'Layak' : 'Tidak Layak'),
      value: _items[key] == 1,
      onChanged: (bool value) {
        setState(() {
          _items[key] = value ? 1 : 0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _items.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Perlengkapan"),
        backgroundColor: const Color(0xFF5B913B),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSantriSearch(),
            const SizedBox(height: 16),
            ...groupedItems.map((key) => _buildItemSwitch(key)).toList(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keteranganController,
              decoration: const InputDecoration(labelText: 'Keterangan'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B913B),
              ),
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildSantriSearch() {
    return Autocomplete<Santri>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<Santri>.empty();
        return santriList.where((s) =>
            s.nama.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
            s.noInduk.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      displayStringForOption: (Santri s) => '${s.nama} (${s.noInduk})',
      onSelected: (Santri selection) {
        setState(() {
          selectedSantri = selection;
          searchController.text = '${selection.nama} (${selection.noInduk})';
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        controller.text = searchController.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            labelText: 'Cari Santri',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (_) => selectedSantri == null ? 'Pilih nama santri' : null,
        );
      },
    );
  }
}
