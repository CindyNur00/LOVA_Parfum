class Parfum {
  String? id;
  String? nama;
  String? brand;
  int? stok;
  int? harga;
  String? deskripsi;

  Parfum({
    this.id,
    this.nama,
    this.brand,
    this.stok,
    this.harga,
    this.deskripsi,
  });

  factory Parfum.fromJson(Map<String, dynamic> json) {
    return Parfum(
      id: json['_id'],
      nama: json['nama_parfum'],
      brand: json['jenis'],
      stok: json['stok_barang'],
      harga: json['harga'],
      deskripsi: json['deskripsi'],
    );
  }
}
