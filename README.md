# LOVA Parfum – Aplikasi Mobile Flutter
LOVA Parfum adalah aplikasi mobile berbasis Flutter yang terhubung dengan CodeIgniter 4 sebagai backend dan MongoDB sebagai database utama. Aplikasi ini dibuat untuk memberikan pengalaman digital dalam membeli parfum secara online dengan fitur-fitur lengkap seperti login, pencarian produk, checkout, dan notifikasi.

# Fitur Utama
Log In – Autentikasi pengguna untuk mengakses aplikasi.

Sign Up – Registrasi akun baru pengguna.

Search Bar Produk – Cari produk parfum dengan cepat.

Filter Search Bar – Filter produk berdasarkan kriteria tertentu (misal: jenis parfum).

Deskripsi Produk – Tampilkan detail lengkap dari setiap parfum.

Button Share Produk – Bagikan detail produk ke aplikasi lain.

Button Add to Cart – Tambahkan parfum ke keranjang belanja.

Checkout – Lanjutkan pembelian dan pilih alamat tujuan.

Pembayaran Menggunakan QRIS – Proses pembayaran digital yang cepat dan aman.

Notifikasi – Lihat status pesanan dan info penting.

Detail Notifikasi – Tampilkan detail dari notifikasi yang diklik.

Notifikasi History – Lihat riwayat notifikasi sebelumnya.

Detail Notifikasi History – Detail dari notifikasi lama.

FAQ – Halaman pertanyaan yang sering diajukan pengguna.

Button Logout – Keluar dari akun pengguna.

# Teknologi yang Digunakan
Frontend: Flutter

Backend: CodeIgniter 4 (REST API)

Database: MongoDB

State Management: Stateful Widgets (manual)

HTTP Request: http package Flutter

Cross-Origin: Konfigurasi CORS di backend (untuk akses dari Flutter Web)

QRIS: Simulasi/placeholder QR-code image

# Cara Menjalankan Aplikasi
1. Clone Repository dari GitHub

git clone https://github.com/CindyNur00/LOVA_Parfum.git
cd lova-parfum-app

2. Jalankan Flutter

flutter pub get
flutter run
Jika menjalankan di Flutter Web, pastikan backend Anda memiliki CORS diaktifkan.

Backend & Database
Backend terletak di folder /api (atau repo terpisah jika perlu).

# Database menggunakan MongoDB dengan koleksi: users, parfum, checkout, notifications.

# Penyimpanan Gambar
Gambar produk disimpan sebagai path string dalam database MongoDB, dan file disimpan di dalam folder publik (/public/uploads).

# Testing
Pastikan API berjalan di http://localhost:8080

Gunakan Postman untuk menguji endpoint seperti /api/login, /api/parfum, /api/pembayaran, dll.

# Deployment

Untuk publikasi:

Kompilasi Flutter menjadi APK: flutter build apk

Gunakan hosting seperti Firebase Hosting jika menggunakan Flutter Web.

# Link Storyboard

https://youtube.com/shorts/hjQcasNLDaE?si=QrKqQDNbVXpSIoTZ

# tubes_parfum

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
