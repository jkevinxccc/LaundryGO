import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model pengguna yang sedang login
class UserModel {
  final int id;
  final String email;
  final String role;
  final String? username;
  final String? alamat;
  final String? noTelp;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.username,
    this.alamat,
    this.noTelp,
  });
}

/// Service Backend Supabase untuk Autentikasi dan Manajemen Database LaundryGO
class SupabaseService {
  // Konfigurasi Kredensial Supabase dari Pengguna
  static const String supabaseUrl = 'https://wcweoyazqvcevsxdfins.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indjd2VveWF6cXZjZXZzeGRmaW5zIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MjcxNjQxMiwiZXhwIjoyMTA4MjkyNDEyfQ.AYxl3oALQW8V4vM5KnXbH8VfDJ41PtEO6qDvFI1xmMI';

  static bool _initialized = false;
  static UserModel? currentUser;

  /// Mengambil instance SupabaseClient
  static SupabaseClient get client => Supabase.instance.client;

  /// Inisialisasi koneksi Supabase saat aplikasi dimulai
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
      _initialized = true;
      if (kDebugMode) {
        print('✅ Supabase initialized successfully: $supabaseUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Supabase init warning: $e');
      }
      _initialized = true;
    }
  }

  /// Registrasi akun Users baru ke tabel Pelanggan
  static Future<UserModel> register({
    required String email,
    required String password,
    String alamat = 'Alamat Belum Diatur',
    String noTelp = '-',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Cek apakah email sudah terdaftar
    final existing = await client
        .from('Pelanggan')
        .select()
        .eq('email_user', cleanEmail)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Email sudah terdaftar. Silakan gunakan email lain atau login.');
    }

    final inserted = await client
        .from('Pelanggan')
        .insert({
          'email_user': cleanEmail,
          'pw_user': cleanPassword,
          'alamat': alamat,
          'no_telp': noTelp,
        })
        .select()
        .single();

    return UserModel(
      id: inserted['id_pelanggan'] as int,
      email: inserted['email_user'] as String,
      role: 'Users',
      alamat: inserted['alamat']?.toString(),
      noTelp: inserted['no_telp']?.toString(),
    );
  }

  /// Autentikasi Login terhubung langsung ke tabel Supabase (Pelanggan / Admin)
  static Future<UserModel> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    try {
      if (role == 'Users') {
        // 1. Cari pengguna di tabel "Pelanggan"
        final data = await client
            .from('Pelanggan')
            .select()
            .eq('email_user', cleanEmail)
            .maybeSingle();

        if (data != null) {
          // Cek verifikasi password
          final storedPw = data['pw_user']?.toString() ?? '';
          if (storedPw != cleanPassword) {
            throw Exception('Kata sandi salah. Silakan coba lagi.');
          }

          currentUser = UserModel(
            id: data['id_pelanggan'] as int,
            email: data['email_user'] as String,
            role: 'Users',
            alamat: data['alamat']?.toString(),
            noTelp: data['no_telp']?.toString(),
          );
          return currentUser!;
        } else {
          // Jika akun belum terdaftar, otomatis buat akun baru di tabel Pelanggan
          final inserted = await client
              .from('Pelanggan')
              .insert({
                'email_user': cleanEmail,
                'pw_user': cleanPassword,
                'alamat': 'Alamat Belum Diatur',
                'no_telp': '-',
              })
              .select()
              .single();

          currentUser = UserModel(
            id: inserted['id_pelanggan'] as int,
            email: inserted['email_user'] as String,
            role: 'Users',
            alamat: inserted['alamat']?.toString(),
            noTelp: inserted['no_telp']?.toString(),
          );
          return currentUser!;
        }
      } else {
        // 2. Cari di tabel "Admin" (untuk Admin)
        final data = await client
            .from('Admin')
            .select()
            .eq('email_admin', cleanEmail)
            .maybeSingle();

        if (data != null) {
          final storedPw = data['pw_admin']?.toString() ?? '';
          if (storedPw != cleanPassword) {
            throw Exception('Kata sandi Admin salah.');
          }

          currentUser = UserModel(
            id: data['id_admin'] as int,
            email: data['email_admin'] as String,
            role: role,
            username: data['username']?.toString(),
          );
          return currentUser!;
        } else {
          // Jika admin belum ada, daftarkan akun Admin baru
          final username = cleanEmail.split('@').first;
          final inserted = await client
              .from('Admin')
              .insert({
                'username': username,
                'email_admin': cleanEmail,
                'pw_admin': cleanPassword,
              })
              .select()
              .single();

          currentUser = UserModel(
            id: inserted['id_admin'] as int,
            email: inserted['email_admin'] as String,
            role: role,
            username: inserted['username']?.toString(),
          );
          return currentUser!;
        }
      }
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception('Gagal menghubungi Supabase: ${e.message}');
      }
      rethrow;
    }
  }

  /// Logout akun
  static Future<void> logout() async {
    currentUser = null;
    try {
      await client.auth.signOut();
    } catch (_) {}
  }

  /// Mengambil daftar layanan laundry dari Supabase tabel Layanan
  static Future<List<Map<String, dynamic>>> getLayanan() async {
    try {
      final List<dynamic> response =
          await client.from('Layanan').select().order('id_layanan');
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) print('Error fetching Layanan: $e');
      return [];
    }
  }

  /// Membuat pesanan baru ke Supabase sesuai struktur:
  /// - Tabel Pesanan: id_pelanggan, id_layanan (item pertama), total_harga, status, id_payment, tanggal_order
  /// - Tabel Detail_Pesanan: satu row per item (id_pesanan, id_layanan, sub_total, catatan)
  /// Payment: Cash=1, Qris=2
  static Future<int> buatPesanan({
    required List<Map<String, dynamic>> items,
    required String metodePembayaran,
  }) async {
    if (currentUser == null) throw Exception('User belum login');
    if (items.isEmpty) throw Exception('Tidak ada item pesanan');

    final idPelanggan = currentUser!.id;
    final int idPayment = metodePembayaran == 'Qris' ? 2 : 1;
    final int totalHarga = items.fold(0, (sum, i) => sum + (i['sub_total'] as int));
    final String tanggalOrder = DateTime.now().toIso8601String().split('T').first;

    // Layanan utama (item pertama) untuk kolom id_layanan di Pesanan
    final int idLayananUtama = items.first['id_layanan'] as int;

    // 1. INSERT ke tabel Pesanan
    final pesananInserted = await client
        .from('Pesanan')
        .insert({
          'id_pelanggan': idPelanggan,
          'id_layanan': idLayananUtama,
          'total_harga': totalHarga,
          'status': 'Baru',
          'id_payment': idPayment,
          'tanggal_order': tanggalOrder,
        })
        .select()
        .single();

    final int idPesanan = pesananInserted['id_pesanan'] as int;

    // 2. INSERT Detail_Pesanan untuk setiap item
    final List<Map<String, dynamic>> details = items.map((item) => {
      'id_pesanan': idPesanan,
      'id_layanan': item['id_layanan'],
      'sub_total': item['sub_total'],
      'catatan': item['catatan'] ?? '',
    }).toList();

    await client.from('Detail_Pesanan').insert(details);

    return idPesanan;
  }

  /// Mengambil riwayat pesanan dari Supabase tabel Pesanan + Detail_Pesanan
  static Future<List<Map<String, dynamic>>> getRiwayatPesanan() async {
    try {
      // Join hanya Detail_Pesanan (tidak Layanan langsung karena tidak ada FK valid)
      var query = client
          .from('Pesanan')
          .select('*, Detail_Pesanan(*)');
      if (currentUser != null && currentUser!.role == 'Users') {
        query = query.eq('id_pelanggan', currentUser!.id);
      }
      final List<dynamic> pesananList =
          await query.order('id_pesanan', ascending: false);

      // Ambil semua data Layanan sekali untuk mapping
      final List<dynamic> layananList =
          await client.from('Layanan').select('id_layanan, nama_layanan, harga_layanan');
      final Map<int, String> layananMap = {
        for (final l in layananList)
          (l['id_layanan'] as int): l['nama_layanan'] as String
      };

      // Inject nama layanan ke setiap Detail_Pesanan
      return pesananList.map<Map<String, dynamic>>((p) {
        final row = Map<String, dynamic>.from(p as Map);
        final details = row['Detail_Pesanan'];
        if (details != null && details is List) {
          row['Detail_Pesanan'] = details.map((d) {
            final detail = Map<String, dynamic>.from(d as Map);
            final idL = detail['id_layanan'] as int?;
            detail['nama_layanan'] = idL != null ? (layananMap[idL] ?? 'Layanan') : 'Layanan';
            return detail;
          }).toList();
        }
        return row;
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching Pesanan: $e');
      return [];
    }
  }
}
