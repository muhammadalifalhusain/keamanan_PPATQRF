class PelanggaranKetertibanResponse {
  final int status;
  final String message;
  final List<PelanggaranKetertiban> data;

  PelanggaranKetertibanResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PelanggaranKetertibanResponse.fromJson(Map<String, dynamic> json) {
    return PelanggaranKetertibanResponse(
      status: json['status'],
      message: json['message'],
      data: List<PelanggaranKetertiban>.from(
        json['data'].map((item) => PelanggaranKetertiban.fromJson(item)),
      ),
    );
  }
}

class PelanggaranKetertiban {
  final int id;
  final String tanggal;
  final String nama;
  final int buangSampah;
  final int menataPeralatan;
  final int tidakBerseragam;
  final String namaPengisi;

  PelanggaranKetertiban({
    required this.id,
    required this.tanggal,
    required this.nama,
    required this.buangSampah,
    required this.menataPeralatan,
    required this.tidakBerseragam,
    required this.namaPengisi,
  });

  factory PelanggaranKetertiban.fromJson(Map<String, dynamic> json) {
    return PelanggaranKetertiban(
      id: json['id'],
      tanggal: json['tanggal'],
      nama: json['nama'],
      buangSampah: json['buangSampah'],
      menataPeralatan: json['menataPeralatan'],
      tidakBerseragam: json['tidakBerseragam'],
      namaPengisi: json['namaPengisi'],
    );
  }
}

class PelanggaranKetertibanRequest {
  final int noInduk;
  final String tanggal;
  final int buangSampah;
  final int menataSeralatan;
  final int tidakBerseragam;

  PelanggaranKetertibanRequest({
    required this.noInduk,
    required this.tanggal,
    required this.buangSampah,
    required this.menataSeralatan,
    required this.tidakBerseragam,
  });

  Map<String, dynamic> toJson() {
    return {
      'noInduk': noInduk,
      'tanggal': tanggal,
      'buangSampah': buangSampah,
      'menataSeralatan': menataSeralatan,
      'tidakBerseragam': tidakBerseragam,
    };
  }
}

class DetailPelanggaranKetertiban {
  final int id;
  final int noInduk;
  final String tanggal;
  final int buangSampah;
  final int menataPeralatan;
  final int tidakBerseragam;

  DetailPelanggaranKetertiban({
    required this.id,
    required this.noInduk,
    required this.tanggal,
    required this.buangSampah,
    required this.menataPeralatan,
    required this.tidakBerseragam,
  });

  factory DetailPelanggaranKetertiban.fromJson(Map<String, dynamic> json) {
    return DetailPelanggaranKetertiban(
      id: json['id'],
      noInduk: json['noInduk'],
      tanggal: json['tanggal'],
      buangSampah: json['buangSampah'],
      menataPeralatan: json['menataPeralatan'],
      tidakBerseragam: json['tidakBerseragam'],
    );
  }
}
