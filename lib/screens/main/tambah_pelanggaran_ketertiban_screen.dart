import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pelanggaran_ketertiban_model.dart';
import '../../services/pelanggaran_ketertiban_service.dart';
import '../../services/santri_service.dart';
import '../../models/santri_model.dart';

class FormPelanggaranKetertibanScreen extends StatefulWidget {
  final int? idEdit;
  const FormPelanggaranKetertibanScreen({super.key, this.idEdit});

  @override
  State<FormPelanggaranKetertibanScreen> createState() => _FormPelanggaranKetertibanScreenState();
}

class _FormPelanggaranKetertibanScreenState extends State<FormPelanggaranKetertibanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController noIndukController = TextEditingController();
  List<Santri> santriList = [];
  Santri? selectedSantri;

  DateTime? _tanggal;
  int _buangSampah = 0;
  int _menata = 0;
  int _tidakBerseragam = 0;

  bool _loading = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchSantri();
    if (widget.idEdit != null) {
      await _loadEditData(widget.idEdit!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      setState(() => santriList = response.data);
    } catch (e) {
      debugPrint("Gagal mengambil data santri: $e");
    }
  }

  Future<void> _loadEditData(int id) async {
    try {
      final data = await PelanggaranKetertibanService.fetchById(id);
      if (data != null) {
        setState(() {
          noIndukController.text = data.noInduk.toString();
          _tanggal = DateTime.tryParse(data.tanggal);
          _buangSampah = data.buangSampah;
          _menata = data.menataPeralatan;
          _tidakBerseragam = data.tidakBerseragam;
          selectedSantri = santriList.firstWhere(
            (s) => s.noInduk == data.noInduk.toString(),
            orElse: () => Santri(
              id: '-1',
              nama: 'Tidak ditemukan',
              noInduk: data.noInduk.toString(),
            ),
          );
          searchController.text = selectedSantri?.nama ?? 'Tidak ditemukan';
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil detail pelanggaran: $e");
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _tanggal == null || selectedSantri == null) {
      _showError('Mohon lengkapi semua data yang diperlukan');
      return;
    }
    
    setState(() => _loading = true);

    final request = PelanggaranKetertibanRequest(
      noInduk: int.tryParse(selectedSantri!.noInduk) ?? -1,
      tanggal: _tanggal!.toIso8601String(),
      buangSampah: _buangSampah,
      menataSeralatan: _menata,
      tidakBerseragam: _tidakBerseragam,
    );

    try {
      bool success;
      if (widget.idEdit != null) {
        success = await PelanggaranKetertibanService.update(widget.idEdit!, request);
      } else {
        success = await PelanggaranKetertibanService.create(request);
      }
      
      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        _showError('Gagal menyimpan data.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  Widget _buildSantriSearch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Autocomplete<Santri>(
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
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Pilih Santri',
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search,
                  color: Colors.indigo[600],
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (_) => selectedSantri == null ? 'Pilih nama santri' : null,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: options.map((Santri option) {
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.indigo[600],
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.nama,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    option.noInduk,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRadioGroup(String label, int groupValue, void Function(int?) onChanged, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(0.8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: groupValue == 0 ? Colors.green.withOpacity(0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: groupValue == 0 ? Colors.green : Colors.grey[300]!,
                      width: groupValue == 0 ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<int>(
                    value: 0,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bagus',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: groupValue == 0 ? Colors.green[700] : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    activeColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: groupValue == 1 ? Colors.red.withOpacity(0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: groupValue == 1 ? Colors.red : Colors.grey[300]!,
                      width: groupValue == 1 ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<int>(
                    value: 1,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tidak',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: groupValue == 1 ? Colors.red[700] : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    activeColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
        ),
      );
    }

    final isEdit = widget.idEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(
          isEdit ? 'Edit Pelanggaran' : 'Tambah Pelanggaran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              isEdit ? Icons.edit : Icons.add_box,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menyimpan data...',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildSantriSearch(),

                    // Date Selection Card
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.indigo[600],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tanggal",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tanggal == null 
                                        ? 'Pilih tanggal'
                                        : _tanggal!.toLocal().toIso8601String().split('T').first,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: _tanggal == null ? FontWeight.w400 : FontWeight.w600,
                                      color: _tanggal == null ? Colors.grey[500] : Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.edit_calendar,
                              color: Colors.indigo[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Violation Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.rule,
                                  color: Colors.indigo[600],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Pelanggaran',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRadioGroup(
                            'Buang Sampah',
                            _buangSampah,
                            (val) => setState(() => _buangSampah = val ?? 0),
                            Icons.delete_sweep,
                            Colors.orange,
                          ),
                          _buildRadioGroup(
                            'Menata Alat',
                            _menata,
                            (val) => setState(() => _menata = val ?? 0),
                            Icons.cleaning_services,
                            Colors.blue,
                          ),
                          _buildRadioGroup(
                            'Tidak Seragam',
                            _tidakBerseragam,
                            (val) => setState(() => _tidakBerseragam = val ?? 0),
                            Icons.checkroom,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),

                    // Submit Button
                    Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.indigo.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isEdit ? Icons.save : Icons.add, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'Simpan' : 'Tambah',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}