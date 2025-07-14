class LoginModel {
  final int id;
  final String nama;
  final String? photo;
  final String accessToken;
  final int expiresIn;

  LoginModel({
    required this.id,
    required this.nama,
    this.photo,
    required this.accessToken,
    required this.expiresIn,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      id: json['id'],
      nama: json['nama'],
      photo: json['photo'],
      accessToken: json['accesToken'],
      expiresIn: json['expiresIn'],
    );
  }
}
