import 'package:flutter/material.dart';
import '../Listorder/pesanan.dart';
import '../Riwayat/riwayat.dart';
import '../Profile/profile.dart';

// ================== WARNA SESUAI FIGMA ==================
// (hapus bagian ini jika digabung ke project yang sudah punya konstanta sama)
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
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    _pages = const [
      DashboardAdminPage(),
      PesananPage(),
      RiwayatPage(),
      ProfilAdminPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(child: _pages[_index]),
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
      onTap: () => setState(() => _index = i),
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

// ================== SCREEN 1: DASHBOARD ==================
class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  // Data pesanan terbaru (ganti dengan data dari database/API)
  static const List<Map<String, dynamic>> _recentOrders = [
    {
      'id': '#LG0012 - Joni',
      'service': 'Cuci Setrika - 2 kg',
      'price': 24400,
      'date': '12 Sep 2025, 10:30',
      'status': 'Baru',
    },
    {
      'id': '#LG0012 - Putri',
      'service': 'Cuci Kering - 2 kg',
      'price': 16000,
      'date': '12 Sep 2025, 10:30',
      'status': 'Baru',
    },
  ];

  // Format angka -> "Rp 24,400"
  String _formatRupiah(int value) {
    final s = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return 'Rp $s';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Pemesanan',
                  value: '42 Pesanan',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Total Selesai',
                  value: '30 Pesanan',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== Total Pelanggan =====
          const _StatCard(
            title: 'Total Pelanggan',
            value: '12 Pelanggan',
            icon: Icons.groups_outlined,
          ),
          const SizedBox(height: 12),

          // ===== Total Pendapatan =====
          const _StatCard(
            title: 'Total Pendapatan',
            value: 'Rp 1,245,000',
            icon: Icons.payments_outlined,
          ),

          const SizedBox(height: 24),

          // ===== Pesanan Terbaru =====
          const Text(
            'Pesanan Terbaru',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

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
            child: Column(
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
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isNew = order['status'] == 'Baru';

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
              color: isNew ? kOrange : kCream,
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
          if (icon != null) Icon(icon, size: 46, color: Colors.black87),
        ],
      ),
    );
  }
}