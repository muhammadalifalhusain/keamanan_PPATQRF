import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/santri_model.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';
import '../../services/santri_service.dart';

class TambahIzinScreen extends StatefulWidget {
  const TambahIzinScreen({super.key});

  @override
  State<TambahIzinScreen> createState() => _TambahIzinScreenState();
}

class _TambahIzinScreenState extends State<TambahIzinScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController kategoriPelanggaranController = TextEditingController();

  List<Santri> santriList = [];
  Santri? selectedSantri;

  DateTime? selectedTanggal;
  TimeOfDay? keluarTime;
  TimeOfDay? kembaliTime;

  int? selectedKategori;
  int? selectedStatus;


  final List<Map<String, dynamic>> kategoriList = [
    {'label': 'Izin Keluar', 'value': 1},
    {'label': 'Izin Pulang', 'value': 2},
  ];

  final List<Map<String, dynamic>> statusList = [
    {'label': 'Diberikan', 'value': 1},
    {'label': 'Dicabut', 'value': 0},
  ];


  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSantri();
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      setState(() => santriList = response.data);
    } catch (_) {}
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSantri == null || selectedTanggal == null || keluarTime == null || kembaliTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = IzinRequest(
      noInduk: selectedSantri!.noInduk,
      tanggal: DateFormat('yyyy-MM-dd').format(selectedTanggal!),
      keluar: keluarTime!.format(context),
      kembali: kembaliTime!.format(context),
      kategori: selectedKategori!,
      status: selectedStatus!,
      kategoriPelanggaran: kategoriPelanggaranController.text,
    );

    final result = await IzinService.postIzin(request);
    setState(() => _isLoading = false);

    if (result) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan izin')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedTanggal = picked);
  }

  Future<void> _pickTime(bool isKeluar) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isKeluar) {
          keluarTime = picked;
        } else {
          kembaliTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    kategoriPelanggaranController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Izin'),
        backgroundColor: const Color(0xFF263238),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSantriSearch(),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Tanggal Izin"),
                subtitle: Text(selectedTanggal == null
                    ? "Belum dipilih"
                    : DateFormat('dd MMM yyyy').format(selectedTanggal!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Jam Keluar"),
                subtitle: Text(keluarTime == null ? "Belum dipilih" : keluarTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Jam Kembali"),
                subtitle: Text(kembaliTime == null ? "Belum dipilih" : kembaliTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                value: selectedKategori,
                items: kategoriList
                    .map((item) => DropdownMenuItem<int>(
                          value: item['value'],
                          child: Text(item['label']),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedKategori = val),
                validator: (value) => value == null ? "Pilih kategori" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                value: selectedStatus,
                items: statusList
                    .map((item) => DropdownMenuItem<int>(
                          value: item['value'],
                          child: Text(item['label']),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedStatus = val),
                validator: (value) => value == null ? "Pilih status" : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: kategoriPelanggaranController,
                decoration: const InputDecoration(
                  labelText: "Kategori Pelanggaran (opsional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isLoading ? "Menyimpan..." : "Simpan"),
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B913B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
