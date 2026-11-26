import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    required String username,
    required String email,
    required String password,
    String alamat = 'Alamat Belum Diatur',
    String noTelp = '-',
  }) async {
    final cleanUsername = username.trim();
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

    final Map<String, dynamic> insertData = {
      'username': cleanUsername,
      'email_user': cleanEmail,
      'pw_user': cleanPassword,
      'alamat': alamat,
      'no_telp': noTelp,
    };

    Map<String, dynamic> inserted;
    try {
      inserted = await client
          .from('Pelanggan')
          .insert(insertData)
          .select()
          .single();
    } catch (e) {
      // Jika kolom 'username' belum ditambahkan di Supabase, fallback tanpa kolom username
      insertData.remove('username');
      inserted = await client
          .from('Pelanggan')
          .insert(insertData)
          .select()
          .single();
    }

    currentUser = UserModel(
      id: inserted['id_pelanggan'] as int,
      email: inserted['email_user'] as String,
      role: 'Users',
      username: (inserted['username']?.toString().isNotEmpty ?? false)
          ? inserted['username']?.toString()
          : cleanUsername,
      alamat: inserted['alamat']?.toString(),
      noTelp: inserted['no_telp']?.toString(),
    );

    return currentUser!;
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

          final rawUsername = data['username']?.toString();
          final resolvedUsername = (rawUsername != null && rawUsername.isNotEmpty)
              ? rawUsername
              : data['email_user'].toString().split('@').first;

          currentUser = UserModel(
            id: data['id_pelanggan'] as int,
            email: data['email_user'] as String,
            role: 'Users',
            username: resolvedUsername,
            alamat: data['alamat']?.toString(),
            noTelp: data['no_telp']?.toString(),
          );
          return currentUser!;
        } else {
          // Jika akun belum terdaftar, otomatis buat akun baru di tabel Pelanggan
          final defaultUsername = cleanEmail.split('@').first;
          final Map<String, dynamic> newUserData = {
            'username': defaultUsername,
            'email_user': cleanEmail,
            'pw_user': cleanPassword,
            'alamat': 'Alamat Belum Diatur',
            'no_telp': '-',
          };

          Map<String, dynamic> inserted;
          try {
            inserted = await client
                .from('Pelanggan')
                .insert(newUserData)
                .select()
                .single();
          } catch (_) {
            newUserData.remove('username');
            inserted = await client
                .from('Pelanggan')
                .insert(newUserData)
                .select()
                .single();
          }

          currentUser = UserModel(
            id: inserted['id_pelanggan'] as int,
            email: inserted['email_user'] as String,
            role: 'Users',
            username: inserted['username']?.toString() ?? defaultUsername,
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

  /// Stream realtime untuk tabel Pesanan
  static Stream<List<Map<String, dynamic>>> streamPesanan() {
    return client.from('Pesanan').stream(primaryKey: ['id_pesanan']);
  }

  /// Update status pesanan di Supabase
  static Future<void> updateStatusPesanan(int idPesanan, String newStatus) async {
    await client
        .from('Pesanan')
        .update({'status': newStatus})
        .eq('id_pesanan', idPesanan);
  }

  /// Mengambil data lengkap pesanan untuk Admin (beserta info Pelanggan & Layanan)
  static Future<List<Map<String, dynamic>>> getAdminOrders() async {
    try {
      final List<dynamic> pesananList = await client
          .from('Pesanan')
          .select('*, Detail_Pesanan(*)')
          .order('id_pesanan', ascending: false);

      // Ambil Pelanggan
      final List<dynamic> pelangganList = await client.from('Pelanggan').select();
      final Map<int, Map<String, dynamic>> pelangganMap = {
        for (final p in pelangganList)
          (p['id_pelanggan'] as int): Map<String, dynamic>.from(p as Map)
      };

      // Ambil Layanan
      final List<dynamic> layananList =
          await client.from('Layanan').select('id_layanan, nama_layanan, harga_layanan');
      final Map<int, Map<String, dynamic>> layananMap = {
        for (final l in layananList)
          (l['id_layanan'] as int): Map<String, dynamic>.from(l as Map)
      };

      return pesananList.map<Map<String, dynamic>>((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        final int idPesanan = row['id_pesanan'] as int;
        final int idPelanggan = row['id_pelanggan'] as int? ?? 0;
        final pel = pelangganMap[idPelanggan];

        // Format username pelanggan
        String customerName = 'User';
        if (pel != null) {
          final uName = pel['username']?.toString().trim();
          final pName = pel['nama_pelanggan']?.toString().trim();
          final email = pel['email_user']?.toString().trim() ?? '';

          if (uName != null && uName.isNotEmpty) {
            customerName = uName;
          } else if (pName != null && pName.isNotEmpty) {
            customerName = pName;
          } else if (email.isNotEmpty) {
            final base = email.contains('@') ? email.split('@').first : email;
            customerName = base.isNotEmpty
                ? base[0].toUpperCase() + base.substring(1)
                : 'User';
          }
        }

        // Format tanggal
        final rawDate = row['tanggal_order']?.toString() ?? '';
        String formattedDate = rawDate;
        if (rawDate.isNotEmpty) {
          try {
            final dt = DateTime.parse(rawDate).toLocal();
            const months = [
              '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
              'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
            ];
            final day = dt.day;
            final m = (dt.month >= 1 && dt.month <= 12) ? months[dt.month] : 'Bln';
            final yr = dt.year;
            final hr = dt.hour.toString().padLeft(2, '0');
            final mn = dt.minute.toString().padLeft(2, '0');
            if (dt.hour == 0 && dt.minute == 0) {
              formattedDate = '$day $m $yr';
            } else {
              formattedDate = '$day $m $yr, $hr:$mn';
            }
          } catch (_) {
            formattedDate = rawDate;
          }
        }

        // Parse detail items
        final List<dynamic> detailsRaw = (row['Detail_Pesanan'] as List?) ?? [];
        final List<Map<String, dynamic>> parsedItems = [];
        String mainServiceName = '';
        int totalKg = 0;

        for (final d in detailsRaw) {
          final detail = Map<String, dynamic>.from(d as Map);
          final idL = detail['id_layanan'] as int? ?? 1;
          final lay = layananMap[idL];
          final String sName = lay != null ? (lay['nama_layanan'] as String) : 'Cuci Kering';
          final int pricePerKg = lay != null ? (lay['harga_layanan'] as int) : 8000;
          final int subTotal = detail['sub_total'] as int? ?? pricePerKg;
          final int qty = pricePerKg > 0 ? (subTotal / pricePerKg).round() : 1;
          totalKg += qty;

          if (mainServiceName.isEmpty) {
            mainServiceName = sName;
          }

          parsedItems.add({
            'name': sName,
            'qty': qty,
            'pricePerKg': pricePerKg,
            'subTotal': subTotal,
            'catatan': detail['catatan']?.toString() ?? '',
            'icon': _getServiceIcon(idL),
          });
        }

        if (mainServiceName.isEmpty) {
          mainServiceName = 'Cuci Kering';
        }

        final serviceSummary = totalKg > 0
            ? '$mainServiceName - $totalKg kg'
            : mainServiceName;

        final rawStatus = row['status']?.toString() ?? 'Baru';

        return {
          'id': '#LG${idPesanan.toString().padLeft(4, '0')}',
          'raw_id': idPesanan,
          'name': customerName,
          'username': customerName,
          'customer_email': pel?['email_user']?.toString() ?? '-',
          'customer_phone': pel?['no_telp']?.toString() ?? '-',
          'customer_address': pel?['alamat']?.toString() ?? '-',
          'service': serviceSummary,
          'price': row['total_harga'] as int? ?? 0,
          'date': formattedDate,
          'status': rawStatus,
          'raw_status': rawStatus,
          'payment_method': (row['id_payment'] == 2) ? 'QRIS' : 'Cash',
          'items': parsedItems,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching Admin orders: $e');
      return [];
    }
  }

  /// Icon helper untuk Layanan
  static IconData _getServiceIcon(int idLayanan) {
    switch (idLayanan) {
      case 1:
        return Icons.local_laundry_service_outlined;
      case 2:
        return Icons.checkroom_rounded;
      case 3:
        return Icons.iron_outlined;
      case 4:
        return Icons.bolt_rounded;
      default:
        return Icons.local_laundry_service_outlined;
    }
  }

  /// Mengambil data statistik untuk Dashboard Admin
  static Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      final pesananRes = await client.from('Pesanan').select('id_pesanan, total_harga, status');
      final pelangganRes = await client.from('Pelanggan').select('id_pelanggan');

      final List<dynamic> pesanan = pesananRes as List;
      final int totalPemesanan = pesanan.length;

      int totalSelesai = 0;
      int totalPendapatan = 0;

      for (final p in pesanan) {
        final st = p['status']?.toString().toLowerCase() ?? '';
        final harga = p['total_harga'] as int? ?? 0;
        if (st == 'selesai') {
          totalSelesai++;
          totalPendapatan += harga;
        }
      }

      // Jika belum ada pesanan yang berstatus selesai, hitung total omset dari seluruh pesanan
      if (totalPendapatan == 0) {
        for (final p in pesanan) {
          totalPendapatan += (p['total_harga'] as int? ?? 0);
        }
      }

      final int totalPelanggan = (pelangganRes as List).length;

      return {
        'totalPemesanan': totalPemesanan,
        'totalSelesai': totalSelesai,
        'totalPelanggan': totalPelanggan,
        'totalPendapatan': totalPendapatan,
      };
    } catch (e) {
      if (kDebugMode) print('Error fetching dashboard stats: $e');
      return {
        'totalPemesanan': 0,
        'totalSelesai': 0,
        'totalPelanggan': 0,
        'totalPendapatan': 0,
      };
    }
  }
}
