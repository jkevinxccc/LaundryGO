import 'dart:async';
import 'package:flutter/material.dart';
import '../Detail/detail_pesanan.dart';
import '../../services/supabase_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // Warna
  static const Color kBg = Color(0xFFB0CBE2);
  static const Color kSage = Color(0xFF9BA87A);
  static const Color kOrange = Color(0xFFDE9154);

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadHistory();
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
          _loadHistory(silent: true);
        }
      });
    } catch (_) {}
  }

  Future<void> _loadHistory({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    final allOrders = await SupabaseService.getAdminOrders();
    final completedOrders = allOrders.where((o) {
      final st = (o['status'] ?? '').toString().toLowerCase();
      return st == 'selesai';
    }).toList();

    if (mounted) {
      setState(() {
        _orders = completedOrders;
        _isLoading = false;
      });
    }
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
      _loadHistory(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Judul
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Text(
                      'Riwayat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.history, size: 22, color: Colors.black),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // List riwayat
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kOrange))
                    : _orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.history_toggle_off_rounded,
                                    size: 48, color: Colors.black38),
                                const SizedBox(height: 8),
                                const Text(
                                  'Belum ada pesanan yang selesai.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: kOrange,
                            onRefresh: () => _loadHistory(),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _orders.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemBuilder: (context, index) =>
                                  _buildOrderCard(_orders[index]),
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
    final String name = (order['name'] ?? '').toString();
    final String title =
        name.isEmpty ? '${order['id']}' : '${order['id']} - $name';

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
                    title,
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

            // Tombol status (oranye sesuai desain riwayat)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                order['status'] ?? 'Selesai',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
