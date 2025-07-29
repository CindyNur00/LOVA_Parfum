class NotificationModel {
  final int id;
  final String namaBarang;
  final String jenis;
  final String deskripsiStatus;
  final String tanggalPembelian;
  final String status;

  NotificationModel({
    required this.id,
    required this.namaBarang,
    required this.jenis,
    required this.deskripsiStatus,
    required this.tanggalPembelian,
    required this.status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      namaBarang: json['nama_barang'],
      jenis: json['jenis'],
      deskripsiStatus: json['deskripsi_status'],
      tanggalPembelian: json['tanggal_pembelian'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'jenis': jenis,
      'deskripsi_status': deskripsiStatus,
      'tanggal_pembelian': tanggalPembelian,
      'status': status,
    };
  }
}
