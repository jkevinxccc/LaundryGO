import 'dart:async';
import 'package:flutter/material.dart';
import '../Detail/detail_pesanan.dart';
import '../../services/supabase_service.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  // Palet Warna Sesuai Desain Figma
  static const Color kBackground = Color(0xFFA9C8E0);
  static const Color kOrange = Color(0xFFDE9556);
  static const Color kSage = Color(0xFF9BA87A);
  static const Color kCream = Color(0xFFFFF3D0);

  final List<String> _filters = ['Semua', 'Pending', 'Diproses', 'Selesai'];
  String _selectedFilter = 'Semua';
  String _query = '';

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadOrders();
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
          _loadOrders(silent: true);
        }
      });
    } catch (_) {}
  }

  Future<void> _loadOrders({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    final data = await SupabaseService.getAdminOrders();
    if (mounted) {
      setState(() {
        _orders = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final target = _selectedFilter;
    final q = _query.toLowerCase();

    return _orders.where((o) {
      final st = (o['status'] ?? '').toString();
      bool matchFilter = false;
      if (_selectedFilter == 'Semua') {
        matchFilter = true;
      } else if (_selectedFilter == 'Pending') {
        matchFilter = (st == 'Pending' || st == 'Baru');
      } else {
        matchFilter = (st.toLowerCase() == target.toLowerCase());
      }

      final matchQuery = q.isEmpty ||
          (o['name'] as String? ?? '').toLowerCase().contains(q) ||
          (o['id'] as String? ?? '').toLowerCase().contains(q) ||
          (o['service'] as String? ?? '').toLowerCase().contains(q);
      return matchFilter && matchQuery;
    }).toList();
  }

  String _rupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }

  Future<void> _openDetail(Map<String, dynamic> order) async {
    final newStatus = await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(builder: (_) => DetailPesananPage(order: order)),
    );
    if (newStatus != null) {
      setState(() => order['status'] = newStatus);
      _loadOrders(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // ===== Search Bar =====
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Cari pesanan',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ===== Filter Chips =====
              Row(
                children: _filters.map((f) {
                  final selected = f == _selectedFilter;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: f == _filters.last ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? kOrange : kCream,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ===== List Pesanan Realtime =====
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kOrange))
                    : orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined, size: 48, color: Colors.black38),
                                const SizedBox(height: 8),
                                Text(
                                  _query.isEmpty
                                      ? 'Tidak ada pesanan $_selectedFilter'
                                      : 'Pesanan tidak ditemukan',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: kOrange,
                            onRefresh: () => _loadOrders(),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: orders.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) => _buildOrderCard(orders[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String displayStatus = order['status'] ?? 'Pending';
    if (displayStatus == 'Baru') displayStatus = 'Pending';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(order),
      child: Container(
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['service'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rupiah(order['price'] as int? ?? 0),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['date'] ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Tombol / Badge Status (warna krem seperti mockup)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                displayStatus,
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
