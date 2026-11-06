import 'package:flutter/material.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  // Palet Warna Sesuai Desain Figma
  static const Color kBackground = Color(0xFFAFCBE2);
  static const Color kOrange = Color(0xFFDB9558);
  static const Color kSage = Color(0xFF97A87A);
  static const Color kCream = Color(0xFFFDF4D2);

  final List<String> _filters = ['Semua', 'Baru', 'Diproses', 'Selesai'];
  String _selectedFilter = 'Semua';
  String _keyword = '';
  int _navIndex = 1;

  // Data dummy (ganti dengan data asli dari state/API)
  final List<Map<String, dynamic>> _orders = [
    {'id': '#LG0012', 'service': 'Cuci Kering - 2 kg', 'price': 16000, 'date': '12 Sep 2025, 10:30', 'status': 'Diproses'},
    {'id': '#LG0012', 'service': 'Cuci Kering - 2 kg', 'price': 16000, 'date': '12 Sep 2025, 10:30', 'status': 'Diproses'},
    {'id': '#LG0012', 'service': 'Cuci Kering - 2 kg', 'price': 16000, 'date': '12 Sep 2025, 10:30', 'status': 'Diproses'},
    {'id': '#LG0012', 'service': 'Cuci Kering - 2 kg', 'price': 16000, 'date': '12 Sep 2025, 10:30', 'status': 'Selesai'},
    {'id': '#LG0012', 'service': 'Cuci Kering - 2 kg', 'price': 16000, 'date': '12 Sep 2025, 10:30', 'status': 'Selesai'},
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((o) {
      final matchStatus =
          _selectedFilter == 'Semua' || o['status'] == _selectedFilter;
      final q = _keyword.toLowerCase();
      final matchSearch = q.isEmpty ||
          (o['id'] as String).toLowerCase().contains(q) ||
          (o['service'] as String).toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();
  }

  String _formatRupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _buildSearchBar(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _buildFilterChips(),
            ),
            Expanded(
              child: orders.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pesanan.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _buildOrderCard(orders[i]),
                    ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  /// Kolom Pencarian Oranye
  Widget _buildSearchBar() {
    return Container(
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
        ],
      ),
    );
  }

  /// Filter Status: Semua, Baru, Diproses, Selesai
  Widget _buildFilterChips() {
    return Row(
      children: List.generate(_filters.length, (index) {
        final filter = _filters[index];
        final isSelected = filter == _selectedFilter;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == _filters.length - 1 ? 0 : 8),
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Kartu Pesanan Hijau Sage
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isDone = order['status'] == 'Selesai';

    return Container(
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
                  order['id'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order['service'],
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatRupiah(order['price']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order['date'],
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
              color: isDone ? kOrange : kCream,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              order['status'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Hijau Sage dengan sudut atas melengkung
  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: kSage,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Beranda'),
          _buildNavItem(1, Icons.receipt_long_rounded, 'Pesanan'),
          _buildNavItem(2, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _navIndex == index;

    return InkWell(
      onTap: () => setState(() => _navIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 34,
              color: isActive ? kOrange : Colors.white,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}