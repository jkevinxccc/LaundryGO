import 'package:flutter/material.dart';
import '../Detail/detail_pesanan.dart';

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
  String _selectedFilter = 'Diproses';
  String _query = '';

  // Data contoh (ganti dengan data dari API / database kamu)
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#LG0012',
      'name': 'KEVIN',
      'service': 'Cuci Kering - 2 kg',
      'price': 16000,
      'date': '12 Sep 2025, 10:30',
      'status': 'Pending',
      'items': [
        {'name': 'Cuci Kering', 'qty': 2, 'pricePerKg': 8000, 'icon': Icons.checkroom},
        {'name': 'Setrika Saja', 'qty': 1, 'pricePerKg': 7000, 'icon': Icons.iron},
      ],
    },
    for (final n in ['Adit', 'Marsha', 'Adhon', 'Maurin'])
      {
        'id': '#LG0012',
        'name': n,
        'service': 'Cuci Kering - 2 kg',
        'price': 16000,
        'date': '12 Sep 2025, 10:30',
        'status': 'Diproses',
        'items': [
          {'name': 'Cuci Kering', 'qty': 2, 'pricePerKg': 8000, 'icon': Icons.checkroom},
        ],
      },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    final target = _selectedFilter;
    final q = _query.toLowerCase();

    return _orders.where((o) {
      final matchFilter = _selectedFilter == 'Semua' || o['status'] == target;
      final matchQuery = q.isEmpty ||
          (o['name'] as String).toLowerCase().contains(q) ||
          (o['id'] as String).toLowerCase().contains(q);
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
    debugPrint('Klik pesanan: ${order['id']} - ${order['name']}');
    final newStatus = await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(builder: (_) => DetailPesananPage(order: order)),
    );
    if (newStatus != null) {
      setState(() => order['status'] = newStatus);
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
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? kOrange : kCream,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // ===== List Pesanan =====
              Expanded(
                child: orders.isEmpty
                    ? const Center(child: Text('Tidak ada pesanan'))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildOrderCard(orders[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kartu pesanan hijau sage
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(order),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSage,
          borderRadius: BorderRadius.circular(12),
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
                    order['service'],
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rupiah(order['price']),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['date'],
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tombol status krem
            Container(
              width: 90,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                order['status'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}