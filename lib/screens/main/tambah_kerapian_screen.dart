import 'package:flutter/material.dart';
import '../../models/kerapian_model.dart';
import '../../services/kerapian_service.dart';
import '../../services/santri_service.dart';
import '../../models/santri_model.dart';
class TambahKerapianScreen extends StatefulWidget {
  final int? idData; 

  const TambahKerapianScreen({super.key, this.idData});

  @override
  State<TambahKerapianScreen> createState() => _TambahKerapianScreenState();
}

class _TambahKerapianScreenState extends State<TambahKerapianScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController noIndukController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController tindakLanjutController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Santri> santriList = [];
  Santri? selectedSantri;

  int sandal = 0;
  int sepatu = 0;
  int boxJajan = 0;
  int alatMandi = 0;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchSantri();
    if (widget.idData != null) {
      _loadDetail(widget.idData!);
    }
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      setState(() {
        santriList = response.data;
      });
    } catch (_) {}
  }

  Future<void> _loadDetail(int id) async {
    setState(() => _loading = true);
    try {
      final data = await KerapianService.fetchDetail(id);
      noIndukController.text = data.id.toString(); 
      tanggalController.text = data.tanggal ?? '-';
      tindakLanjutController.text = data.tindakLanjut ?? '-';
      sandal = data.sandal;
      sepatu = data.sepatu;
      boxJajan = data.boxJajan;
      alatMandi = data.alatMandi;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil data: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  int _convertStringToValue(String status) {
    return status.toLowerCase().contains("ditata") ? 1 : 0;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSantri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Santri dan kategori wajib diisi')),
      );
      return;
    }
    final request = PostKerapianRequest(
      noInduk: selectedSantri!.noInduk,
      tanggal: tanggalController.text,
      sandal: sandal,
      sepatu: sepatu,
      boxJajan: boxJajan,
      alatMandi: alatMandi,
      tindakLanjut: tindakLanjutController.text,
    );

    setState(() => _loading = true);

    try {
      if (widget.idData == null) {
        await KerapianService.createKerapian(request);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil ditambahkan')));
      } else {
        await KerapianService.updateKerapian(widget.idData!, request);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));
      }

      Navigator.pop(context, true); // kirim tanda berhasil
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildRadio(String label, int value, int groupValue, void Function(int?) onChanged) {
    return Row(
      children: [
        Radio(value: value, groupValue: groupValue, onChanged: onChanged),
        Text(label),
      ],
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.idData != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Kerapian' : 'Tambah Kerapian')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSantriSearch(),
                    TextFormField(
                      controller: tanggalController,
                      decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 10),
                    _buildRadioGroup('Sandal', sandal, (val) => setState(() => sandal = val!)),
                    _buildRadioGroup('Sepatu', sepatu, (val) => setState(() => sepatu = val!)),
                    _buildRadioGroup('Box Jajan', boxJajan, (val) => setState(() => boxJajan = val!)),
                    _buildRadioGroup('Alat Mandi', alatMandi, (val) => setState(() => alatMandi = val!)),
                    TextFormField(
                      controller: tindakLanjutController,
                      decoration: const InputDecoration(labelText: 'Tindak Lanjut'),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Data'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRadioGroup(String label, int groupValue, void Function(int?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            _buildRadio('Tidak Ditata', 0, groupValue, onChanged),
            _buildRadio('Ditata', 1, groupValue, onChanged),
          ],
        ),
      ],
    );
  }
}
