import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/perlengkapan_model.dart';
import '../../models/santri_model.dart';
import '../../services/perlengkapan_service.dart';
import '../../services/santri_service.dart';
import '../../utils/perlengkapan_items.dart';

class TambahPerlengkapanScreen extends StatefulWidget {
  final int? perlengkapanId; // NULL berarti tambah, tidak null berarti edit

  const TambahPerlengkapanScreen({super.key, this.perlengkapanId});

  @override
  State<TambahPerlengkapanScreen> createState() => _TambahPerlengkapanScreenState();
}

class _TambahPerlengkapanScreenState extends State<TambahPerlengkapanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String _tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<Santri> santriList = [];
  Santri? selectedSantri;
  Map<String, int> _items = Map<String, int>.from(defaultItems);

  bool isLoading = true;
  EditPerlengkapanModel? editData;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchSantri();

    if (widget.perlengkapanId != null) {
      await _fetchEditData(widget.perlengkapanId!);
      _applyEditData();
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      santriList = response.data;
    } catch (e) {
      debugPrint("Gagal mengambil data santri: $e");
    }
  }

  Future<void> _fetchEditData(int id) async {
    try {
      editData = await PerlengkapanService.getPerlengkapanById(id);
    } catch (e) {
      debugPrint("Gagal mengambil detail perlengkapan: $e");
    }
  }

  void _applyEditData() {
    if (editData == null) return;
    final edit = editData!;

    _tanggal = edit.tanggal;
    _keteranganController.text = edit.keterangan;

    selectedSantri = santriList.firstWhere(
      (s) => s.noInduk == edit.noInduk,
      orElse: () => Santri(id: '-1', nama: 'Tidak ditemukan', noInduk: edit.noInduk),
    );

    searchController.text = selectedSantri?.nama ?? 'Tidak ditemukan';

    _items.clear();
    _items.addAll(defaultItems);

    defaultItems.keys.forEach((key) {
      final value = edit.toJson()[key];
      _items[key] = int.tryParse(value?.toString() ?? '0') ?? 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = PostPerlengkapanRequest(
      noInduk: selectedSantri!.noInduk,
      tanggal: _tanggal,
      items: _items,
      keterangan: _keteranganController.text,
      namaPengisi: "Admin",
    );

    try {
      bool success;

      if (widget.perlengkapanId != null) {
        success = await PerlengkapanService.updatePerlengkapan(widget.perlengkapanId!, request.toJson());
      } else {
        success = await PerlengkapanService.postPerlengkapan(request.toJson());
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        _showError('Gagal menyimpan data.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_tanggal),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggal = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildKelayakanField(String label) {
    int? value = _items[label] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          ToggleButtons(
            borderRadius: BorderRadius.circular(10),
            isSelected: [value == 0, value == 1],
            onPressed: (index) {
              setState(() {
                _items[label] = index;
              });
            },
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Layak ✅')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Tidak Layak ❌')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isEdit = widget.perlengkapanId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Perlengkapan' : 'Tambah Perlengkapan'),
        backgroundColor: const Color(0xFF5B913B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: searchController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Nama Santri',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final selected = await showSearch<Santri?>(
                        context: context,
                        delegate: SantriSearchDelegate(santriList),
                      );
                      if (selected != null) {
                        setState(() {
                          selectedSantri = selected;
                          searchController.text = selected.nama;
                        });
                      }
                    },
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Santri wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Tanggal: "),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_tanggal),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              const Divider(),
              const Text('Jumlah Perlengkapan:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._items.keys.map((k) => _buildKelayakanField(k)).toList(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(isEdit ? Icons.save : Icons.add),
                onPressed: _submit,
                label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B913B),
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Santri Search Delegate (unchanged)
class SantriSearchDelegate extends SearchDelegate<Santri?> {
  final List<Santri> santriList;
  SantriSearchDelegate(this.santriList);

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => _buildList();
  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final suggestions = santriList
        .where((s) => s.nama.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final santri = suggestions[index];
        return ListTile(
          title: Text(santri.nama),
          onTap: () => close(context, santri),
        );
      },
    );
  }
}
