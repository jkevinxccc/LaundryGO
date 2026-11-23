import 'package:flutter/material.dart';

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

  // Data dummy (ganti dengan data dari API / database)
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#LG0012',
      'name': 'KEVIN',
      'service': 'Cuci Kering - 2 kg',
      'price': 16000,
      'date': '12 Sep 2025, 10:30',
      'status': 'Selesai',
    },
    {
      'id': '#LG0012',
      'name': '',
      'service': 'Cuci Kering - 2 kg',
      'price': 16000,
      'date': '12 Sep 2025, 10:30',
      'status': 'Selesai',
    },
  ];

  // Format rupiah: 16000 -> "Rp 16,000"
  String _rupiah(int value) {
    final s = value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
    return 'Rp $s';
  }

  void _openDetail(Map<String, dynamic> order) {
    // TODO: navigasi ke halaman detail
    // Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(order: order)));
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
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildOrderCard(_orders[index]),
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
                    title,
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

            // Tombol status (oranye sesuai desain riwayat)
            Container(
              width: 90,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
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