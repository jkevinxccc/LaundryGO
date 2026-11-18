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
        // 2. Cari di tabel "Admin" (untuk Staff atau Admin)
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

  /// Mengambil riwayat pesanan dari Supabase tabel Pesanan
  static Future<List<Map<String, dynamic>>> getRiwayatPesanan() async {
    try {
      var query = client.from('Pesanan').select('*, Layanan(*)');
      if (currentUser != null && currentUser!.role == 'Users') {
        query = query.eq('id_pelanggan', currentUser!.id);
      }
      final List<dynamic> response = await query.order('id_pesanan', ascending: false);
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) print('Error fetching Pesanan: $e');
      return [];
    }
  }
}
