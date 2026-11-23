import 'package:flutter/material.dart';
import 'pesan_layanan.dart';

import '../services/supabase_service.dart';
import 'editprofile/edit_profile.dart';
import 'tentang/tentang.dart';
import 'bantuan/bantuan.dart';

void main() => runApp(const LaundryApp());

class LaundryApp extends StatelessWidget {
  const LaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LaundryGO',
      theme: ThemeData(useMaterial3: true),
      home: const MainPage(),
    );
  }
}

// Aliases for compatibility
typedef DashboardPage = MainPage;
typedef UserDashboardPage = MainPage;

// ================== WARNA SESUAI FIGMA ==================
const kBackground = Color(0xFFAFCBE2);
const kCard = Color(0xFFFDF3D0);
const kButton = Color(0xFFDB9558);
const kNavBar = Color(0xFF97A87A);
const kIconBox = Color(0xFFD9D9D9);
const kBlue = Color(0xFF2F88FF);

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;
  int _pesananRefreshKey = 0; // increment setiap kali tab Pesanan dibuka

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: null,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            const BerandaPage(),
            PesananPage(key: ValueKey('pesanan_$_pesananRefreshKey')),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: kNavBar,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Beranda'),
            _navItem(1, Icons.description_rounded, 'Pesanan'),
            _navItem(2, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final bool isSelected = _index == i;
    final Color itemColor = isSelected ? kButton : Colors.white;

    return InkWell(
      onTap: () {
        setState(() {
          if (i == 1 && _index != 1) {
            // Setiap kali tab Pesanan dibuka dari tab lain → refresh data
            _pesananRefreshKey++;
          }
          _index = i;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: itemColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== SCREEN 1: BERANDA ==================
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  void _navigateToPesanLayanan(BuildContext context, [String? category]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PesanLayananPage(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Teks
          const Text(
            'Halo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Layanan laundry cepat dan terpercaya',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 18),

          // ===== Banner Cream Card =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'Tinggal '),
                            TextSpan(
                              text: 'Klik,',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '\nBaju Bersih Kembali Nyentrik.'),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.waves_rounded, size: 42, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 14),

                // Tombol "Pesan Sekarang" -> Navigasi ke Pesan Layanan
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => _navigateToPesanLayanan(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButton,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== 4 Ikon Menu Cepat -> Semuanya mengarah ke Pesan Layanan =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickMenu(
                icon: Icons.checkroom_rounded,
                label: 'Cuci Kering',
                onTap: () => _navigateToPesanLayanan(context, 'cuci_kering'),
              ),
              _QuickMenu(
                icon: Icons.local_laundry_service_rounded,
                label: 'Cuci Setrika',
                onTap: () => _navigateToPesanLayanan(context, 'cuci_setrika'),
              ),
              _QuickMenu(
                icon: Icons.iron_rounded,
                label: 'Setrika Saja',
                onTap: () => _navigateToPesanLayanan(context, 'setrika_saja'),
              ),
              _QuickMenu(
                icon: Icons.thunderstorm_rounded,
                label: 'Express',
                onTap: () => _navigateToPesanLayanan(context, 'express'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ===== Kategori Layanan Cream Card =====
          const Text(
            'Kategori Layanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _CategoryItem(
                  icon: Icons.checkroom_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Pakaian Harian',
                  subtitle: 'Kemeja, Kaos, Celana, dll',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
                const SizedBox(height: 16),
                _CategoryItem(
                  icon: Icons.menu_book_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Bed Cover',
                  subtitle: 'Selimut, Sprei, Sarung Bantal',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
                const SizedBox(height: 16),
                _CategoryItem(
                  icon: Icons.toys_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Boneka',
                  subtitle: 'Boneka Kesayangan',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
                const SizedBox(height: 16),
                _CategoryItem(
                  icon: Icons.curtains_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Lainnya',
                  subtitle: 'Jas, Gorden, dll',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ================== SCREEN: PESANAN TAB ==================
class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  static const Color kOrange = Color(0xFFDB9558);
  static const Color kSage = Color(0xFF97A87A);
  static const Color kCream = Color(0xFFFDF4D2);

  final List<String> _filters = ['Semua', 'Baru', 'Diproses', 'Selesai'];
  String _selectedFilter = 'Semua';
  String _keyword = '';

  List<Map<String, dynamic>> _rawOrders = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  /// Ambil data dari Supabase
  Future<void> _loadPesanan() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final data = await SupabaseService.getRiwayatPesanan();
      if (mounted) {
        setState(() {
          _rawOrders = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Gagal memuat pesanan. Periksa koneksi internet.';
          _isLoading = false;
        });
      }
    }
  }

  /// Ambil nilai dari map dengan beberapa kemungkinan nama kolom
  String _get(Map<String, dynamic> m, List<String> keys, [String fallback = '']) {
    for (final k in keys) {
      if (m.containsKey(k) && m[k] != null) return m[k].toString();
    }
    return fallback;
  }

  /// Konversi raw row Supabase → map siap pakai di UI
  Map<String, String> _parse(Map<String, dynamic> row) {
    // ID
    final rawId = _get(row, ['id_pesanan', 'id'], '???');
    final id = '#LG${rawId.toString().padLeft(4, '0')}';

    // Nama layanan dari Detail_Pesanan (sudah di-inject nama_layanan)
    String service = '';
    final detailRaw = row['Detail_Pesanan'];
    if (detailRaw != null && detailRaw is List && detailRaw.isNotEmpty) {
      final names = <String>[];
      for (final d in detailRaw) {
        if (d is Map<String, dynamic>) {
          final nm = _get(d, ['nama_layanan', 'name'], '');
          if (nm.isNotEmpty && !names.contains(nm)) names.add(nm);
        }
      }
      service = names.join(', ');
    }
    if (service.isEmpty) service = 'Laundry';

    // Total harga
    final hargaRaw = int.tryParse(
        _get(row, ['total_harga', 'harga', 'total', 'total_bayar'], '0'));
    final harga = hargaRaw ?? 0;

    // Status
    String status = _get(row, ['status', 'status_pesanan', 'kondisi'], 'Baru');
    final sl = status.toLowerCase();
    if (sl.contains('selesai') || sl.contains('done') || sl.contains('finish')) {
      status = 'Selesai';
    } else if (sl.contains('proses') || sl.contains('process') || sl.contains('progress')) {
      status = 'Diproses';
    } else {
      status = 'Baru';
    }

    // Tanggal
    String tanggal = '';
    final rawDate = _get(row, ['tanggal_order', 'tanggal_pesan', 'created_at', 'tanggal', 'date'], '');
    if (rawDate.isNotEmpty) {
      try {
        final dt = DateTime.tryParse(rawDate);
        if (dt != null) {
          final local = dt.toLocal();
          const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
            'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
          final hh = local.hour.toString().padLeft(2, '0');
          final mm = local.minute.toString().padLeft(2, '0');
          tanggal = '${local.day} ${bulan[local.month]} ${local.year}, $hh:$mm';
        } else {
          tanggal = rawDate;
        }
      } catch (_) {
        tanggal = rawDate;
      }
    }

    return {
      'id': id,
      'service': service,
      'harga': harga.toString(),
      'status': status,
      'tanggal': tanggal,
    };
  }

  /// Orders sudah di-parse + difilter
  List<Map<String, String>> get _filteredOrders {
    final parsed = _rawOrders.map(_parse).toList();
    return parsed.where((o) {
      final matchStatus =
          _selectedFilter == 'Semua' || o['status'] == _selectedFilter;
      final q = _keyword.toLowerCase().trim();
      final matchSearch = q.isEmpty ||
          o['id']!.toLowerCase().contains(q) ||
          o['service']!.toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();
  }

  String _formatRupiah(int value) {
    if (value == 0) return 'Rp 0';
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Search Bar =====
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kOrange,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: kCream.withValues(alpha: 0.9), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (text) => setState(() => _keyword = text),
                    cursorColor: Colors.white,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Cari pesanan',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: kCream.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                // Tombol refresh
                GestureDetector(
                  onTap: _loadPesanan,
                  child: Icon(Icons.refresh_rounded,
                      color: kCream.withValues(alpha: 0.9), size: 20),
                ),
              ],
            ),
          ),
        ),

        // ===== Filter Chips =====
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: List.generate(_filters.length, (index) {
              final filter = _filters[index];
              final isSelected = filter == _selectedFilter;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: index == _filters.length - 1 ? 0 : 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = filter),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? kOrange : kCream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // ===== Konten Utama =====
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    // Loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kOrange),
            SizedBox(height: 14),
            Text('Memuat pesanan...', style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }

    // Error
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.black38),
            const SizedBox(height: 10),
            Text(_errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _loadPesanan,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    final orders = _filteredOrders;

    // Kosong
    if (_rawOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: Colors.black.withValues(alpha: 0.2)),
            const SizedBox(height: 14),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pesanan yang kamu buat akan\nmuncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    // Filter kosong
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: Colors.black.withValues(alpha: 0.2)),
            const SizedBox(height: 10),
            Text(
              'Tidak ada pesanan "$_keyword"',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kOrange,
      onRefresh: _loadPesanan,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _buildOrderCard(orders[i]),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, String> order) {
    final status = order['status'] ?? 'Baru';
    final isDone = status == 'Selesai';
    final harga = int.tryParse(order['harga'] ?? '0') ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kSage,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['id'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order['service'] ?? '-',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRupiah(harga),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if ((order['tanggal'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    order['tanggal']!,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 80,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDone ? kOrange : kCream,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== SCREEN: PROFILE TAB ==================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),

          // ===== Card Info User =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFD9D9D9),
                  child: Icon(Icons.person_rounded, size: 38, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SupabaseService.currentUser?.username ??
                            SupabaseService.currentUser!.email.split('@').first,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SupabaseService.currentUser?.email ?? 'oamalia@gmail.com',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SupabaseService.currentUser?.noTelp ?? '089111111234',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SupabaseService.currentUser?.alamat ??
                            'Jl. Merdeka No. 45, Kel. Tamansari',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ===== Stats Row =====
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Total Pesanan Selesai',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '3',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Total Pesanan Diproses',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '2',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===== Menu Items =====
          _ProfileMenuItem(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _ProfileMenuItem(
            icon: Icons.info_outline_rounded,
            label: 'Tentang Aplikasi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TentangPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Bantuan',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BantuanPage()),
              );
            },
          ),

          const SizedBox(height: 20),

          // ===== Tombol Keluar =====
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.black87, size: 20),
              label: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kButton,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

// ================== HELPER WIDGETS ==================
class _QuickMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickMenu({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 38, color: kBlue),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final Color iconBoxColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.iconBoxColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBoxColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
