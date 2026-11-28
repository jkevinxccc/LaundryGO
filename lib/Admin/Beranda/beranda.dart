import 'dart:async';
import 'package:flutter/material.dart';
import '../Listorder/pesanan.dart';
import '../Riwayat/riwayat.dart';
import '../Profile/profile.dart';
import '../Detail/detail_pesanan.dart';
import '../../services/supabase_service.dart';

// ================== WARNA SESUAI FIGMA ==================
const kBackground = Color(0xFFAFCBE2);
const kCream = Color(0xFFFDF3D0);
const kOrange = Color(0xFFDB9558);
const kSage = Color(0xFF97A87A);

class AdminMainPage extends StatefulWidget {
  final int initialIndex;

  const AdminMainPage({super.key, this.initialIndex = 0})
      : assert(initialIndex >= 0 && initialIndex < 4);

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  late int _index;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardAdminPage(
        key: ValueKey('dash_$_refreshCounter'),
        onNavigateToListOrder: () => setState(() => _index = 1),
      ),
      PesananPage(key: ValueKey('list_$_refreshCounter')),
      RiwayatPage(key: ValueKey('hist_$_refreshCounter')),
      const ProfilAdminPage(),
    ];

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: kSage,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Dashboard'),
            _navItem(1, Icons.description_rounded, 'List Order'),
            _navItem(2, Icons.history_rounded, 'Riwayat'),
            _navItem(3, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final bool isSelected = _index == i;
    final Color itemColor = isSelected ? kOrange : Colors.white;

    return InkWell(
      onTap: () {
        setState(() {
          if (_index != i) _refreshCounter++;
          _index = i;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

// ================== SCREEN 1: DASHBOARD ADMIN ==================
class DashboardAdminPage extends StatefulWidget {
  final VoidCallback? onNavigateToListOrder;

  const DashboardAdminPage({super.key, this.onNavigateToListOrder});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  Map<String, dynamic> _stats = {
    'totalPemesanan': 0,
    'totalSelesai': 0,
    'totalPelanggan': 0,
    'totalPendapatan': 0,
  };

  List<Map<String, dynamic>> _recentOrders = [];
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _initRealtime();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  void _initRealtime() {
    try {
      _realtimeSubscription = SupabaseService.streamPesanan().listen((_) {
        if (mounted) {
          _loadDashboardData(silent: true);
        }
      });
    } catch (_) {}
  }

  Future<void> _loadDashboardData({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait([
        SupabaseService.getAdminDashboardStats(),
        SupabaseService.getAdminOrders(),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as Map<String, dynamic>;
          final allOrders = results[1] as List<Map<String, dynamic>>;

          // Pastikan total pendapatan mencakup seluruh pesanan yang dilakukan user
          final int totalFromOrders = allOrders.fold<int>(
            0,
            (sum, o) => sum + ((o['price'] as num?)?.toInt() ?? 0),
          );
          if (totalFromOrders > (_stats['totalPendapatan'] as int? ?? 0)) {
            _stats['totalPendapatan'] = totalFromOrders;
          }

          // Khusus pesanan baru yang dibuat dari user ('Baru' atau 'Pending').
          // Jika status sudah diubah menjadi 'Diproses' atau 'Selesai', otomatis hilang dari Pesanan Terbaru.
          final newOrders = allOrders.where((o) {
            final st = o['status']?.toString().toLowerCase().trim() ?? '';
            return st == 'baru' || st == 'pending';
          }).toList();
          _recentOrders = newOrders.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatRupiah(int value) {
    final s = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return 'Rp $s';
  }

  Future<void> _openDetail(Map<String, dynamic> order) async {
    final newStatus = await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(builder: (_) => DetailPesananPage(order: order)),
    );
    if (newStatus != null) {
      _loadDashboardData(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: kOrange))
        : RefreshIndicator(
            color: kOrange,
            onRefresh: () => _loadDashboardData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Judul Dashboard =====
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== Total Pemesanan & Total Selesai =====
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Pemesanan',
                          value: '${_stats['totalPemesanan']} Pesanan',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Selesai',
                          value: '${_stats['totalSelesai']} Pesanan',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ===== Total Pelanggan =====
                  _StatCard(
                    title: 'Total Pelanggan',
                    value: '${_stats['totalPelanggan']} Pelanggan',
                    icon: Icons.groups_outlined,
                  ),
                  const SizedBox(height: 12),

                  // ===== Total Pendapatan =====
                  _StatCard(
                    title: 'Total Pendapatan',
                    value: _formatRupiah(_stats['totalPendapatan'] as int? ?? 0),
                    icon: Icons.payments_outlined,
                  ),

                  const SizedBox(height: 24),

                  // ===== Header Pesanan Terbaru & Tombol Lihat Semua =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pesanan Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.onNavigateToListOrder != null)
                        TextButton(
                          onPressed: widget.onNavigateToListOrder,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Container Krem Pembungkus Pesanan Terbaru Sesuai Mockup
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kCream,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _recentOrders.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'Belum ada pesanan baru masuk',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (int i = 0; i < _recentOrders.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                _buildOrderCard(_recentOrders[i]),
                              ],
                            ],
                          ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'Baru').toString();
    final isNewOrPending = status == 'Baru' || status == 'Pending';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(order),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSage,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order['id']} - ${order['name']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order['service'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatRupiah(order['price'] as int? ?? 0),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order['date'] ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
            // Badge Status
            Container(
              width: 84,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isNewOrPending ? kOrange : kCream,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              child: Text(
                isNewOrPending ? 'Baru' : status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== HELPER WIDGETS ==================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const _StatCard({required this.title, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kOrange, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          if (icon != null) Icon(icon, size: 44, color: Colors.black87),
        ],
      ),
    );
  }
}
