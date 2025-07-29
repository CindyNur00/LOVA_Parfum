class users {
  final String? id;
  final String username;
  final String email;
  final String? password; // opsional kalau gak perlu simpan lokal
  final String? phone;
  final String? address;
  final String? token;

  users({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.phone,
    this.address,
    this.token,
  });

  factory users.fromJson(Map<String, dynamic> json) {
    return users(
      id: json['_id']?['\$oid'] ?? json['_id']?.toString(),
      username: json['username'],
      email: json['email'],
      password: json['password'],      // hanya kalau API ngirim ini
      phone: json['no_hp'],            // sesuaikan dengan nama field di API
      address: json['alamat'],         // sesuaikan dengan nama field di API
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'no_hp': phone,
      'alamat': address,
      'token': token,
    };
  }
}
