import 'package:flutter/material.dart';
import '../utils/partition_helper.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  static const Color kBackground = Color(0xFFAFCBE2);
  static const Color kOrange = Color(0xFFDB9558);
  static const Color kSage = Color(0xFF97A87A);
  static const Color kCream = Color(0xFFFDF4D2);

  final List<String> _filters = ['Semua', 'Baru', 'Diproses', 'Selesai'];
  String _selectedFilter = 'Semua';

  final List<String> _methods = [
    'Semua',
    'Cuci Kering',
    'Cuci Setrika',
    'Setrika Saja',
    'Express',
  ];
  String _selectedMethod = 'Semua';

  String _selectedSort = 'default'; // 'default', 'price_asc', 'price_desc', 'partition'
  String _keyword = '';
  int? _customPivot;
  String _partitionSide = 'all'; // 'all', 'left', 'right'
  int _navIndex = 1;

  final List<Map<String, dynamic>> _orders = [
    {'id': '#LG0011', 'service': 'Cuci Komplit - 3 kg', 'price': 24000, 'date': '13 Sep 2025, 09:15', 'status': 'Baru'},
    {'id': '#LG0012', 'service': 'Cuci Kering - 2 kg', 'price': 16000, 'date': '12 Sep 2025, 10:30', 'status': 'Diproses'},
    {'id': '#LG0013', 'service': 'Setrika Saja - 4 kg', 'price': 20000, 'date': '11 Sep 2025, 14:00', 'status': 'Diproses'},
    {'id': '#LG0014', 'service': 'Cuci Kilat Express - 2 kg', 'price': 30000, 'date': '08 Sep 2025, 16:20', 'status': 'Selesai'},
    {'id': '#LG0015', 'service': 'Cuci Kering - 1 kg', 'price': 8000, 'date': '05 Sep 2025, 11:45', 'status': 'Selesai'},
  ];

  bool _matchesMethod(String service) {
    if (_selectedMethod == 'Semua') return true;
    final s = service.toLowerCase();
    switch (_selectedMethod) {
      case 'Cuci Kering':
        return s.contains('cuci kering') || s.contains('kering');
      case 'Cuci Setrika':
        return s.contains('cuci setrika') ||
            s.contains('komplit') ||
            (s.contains('cuci') && s.contains('setrika'));
      case 'Setrika Saja':
        return s.contains('setrika saja') ||
            (s.contains('setrika') && !s.contains('cuci'));
      case 'Express':
        return s.contains('express') ||
            s.contains('expres') ||
            s.contains('kilat');
      default:
        return s.contains(_selectedMethod.toLowerCase());
    }
  }

  List<Map<String, dynamic>> get _baseFilteredOrders {
    return _orders.where((o) {
      final matchStatus =
          _selectedFilter == 'Semua' || o['status'] == _selectedFilter;
      final q = _keyword.toLowerCase();
      final matchSearch = q.isEmpty ||
          (o['id'] as String).toLowerCase().contains(q) ||
          (o['service'] as String).toLowerCase().contains(q);
      final matchMethod = _matchesMethod(o['service']?.toString() ?? '');

      return matchStatus && matchSearch && matchMethod;
    }).toList();
  }

  PartitionResult<Map<String, dynamic>> get _partitionResult {
    return PartitionHelper.partition<Map<String, dynamic>>(
      items: _baseFilteredOrders,
      valueExtractor: (o) => (o['price'] as num?)?.toInt() ?? 0,
      customPivot: _customPivot,
    );
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final list = List<Map<String, dynamic>>.from(_baseFilteredOrders);

    if (_selectedSort == 'price_asc') {
      list.sort((a, b) {
        final pA = (a['price'] as num?)?.toInt() ?? 0;
        final pB = (b['price'] as num?)?.toInt() ?? 0;
        return pA.compareTo(pB);
      });
      return list;
    } else if (_selectedSort == 'price_desc') {
      list.sort((a, b) {
        final pA = (a['price'] as num?)?.toInt() ?? 0;
        final pB = (b['price'] as num?)?.toInt() ?? 0;
        return pB.compareTo(pA);
      });
      return list;
    } else if (_selectedSort == 'partition') {
      final pRes = _partitionResult;
      if (_partitionSide == 'left') {
        return pRes.left;
      } else if (_partitionSide == 'right') {
        return pRes.right;
      } else {
        return pRes.partitionedList;
      }
    }

    return list;
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

  void _onBottomNavTapped(int index) {
    setState(() => _navIndex = index);
    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header =====
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                      }
                    },
                  ),
                  const Text(
                    'Riwayat Pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // ===== Search Bar =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _buildSearchBar(),
            ),

            // ===== Filter Chips =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _buildFilterChips(),
            ),

            // ===== Sort Options (Seperti Search Shopee) =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_vert_rounded, size: 18, color: Colors.black87),
                      SizedBox(width: 4),
                      Text(
                        'Urutkan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildSortChip(
                            label: 'Default',
                            type: 'default',
                            icon: Icons.access_time_rounded,
                          ),
                          const SizedBox(width: 6),
                          _buildSortChip(
                            label: 'Harga Terendah',
                            type: 'price_asc',
                            icon: Icons.arrow_upward_rounded,
                          ),
                          const SizedBox(width: 6),
                          _buildSortChip(
                            label: 'Harga Tertinggi',
                            type: 'price_desc',
                            icon: Icons.arrow_downward_rounded,
                          ),
                          const SizedBox(width: 6),
                          _buildSortChip(
                            label: _selectedMethod == 'Semua'
                                ? 'Filter'
                                : 'Filter ($_selectedMethod)',
                            type: 'partition',
                            icon: Icons.filter_list_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Partition Control Card =====
            if (_selectedSort == 'partition' && _baseFilteredOrders.isNotEmpty)
              _buildPartitionControlCard(_partitionResult),

            // ===== Order List =====
            Expanded(
              child: orders.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pesanan.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : (_selectedSort == 'partition' && _partitionSide == 'all')
                      ? ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          children: [
                            // Header Sisi Kiri
                            _buildPartitionSectionHeader(
                              title: 'Sisi Kiri: Harga ≤ ${_formatRupiah(_partitionResult.pivotValue)}',
                              count: _partitionResult.leftCount,
                              isLeft: true,
                            ),
                            const SizedBox(height: 8),
                            if (_partitionResult.left.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Tidak ada pesanan di sisi kiri (≤ pivot).',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              ..._partitionResult.left.map((o) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildOrderCard(o),
                                  )),

                            const SizedBox(height: 6),
                            // Garis Pembatas Nilai Pivot
                            _buildPivotDivider(_partitionResult.pivotValue),
                            const SizedBox(height: 12),

                            // Header Sisi Kanan
                            _buildPartitionSectionHeader(
                              title: 'Sisi Kanan: Harga > ${_formatRupiah(_partitionResult.pivotValue)}',
                              count: _partitionResult.rightCount,
                              isLeft: false,
                            ),
                            const SizedBox(height: 8),
                            if (_partitionResult.right.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Tidak ada pesanan di sisi kanan (> pivot).',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              ..._partitionResult.right.map((o) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildOrderCard(o),
                                  )),
                          ],
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _buildOrderCard(orders[i]),
                        ),
            ),

            // ===== Bottom Nav =====
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildSortChip({
    required String label,
    required String type,
    required IconData icon,
  }) {
    final isSelected = _selectedSort == type;
    return InkWell(
      onTap: () => setState(() => _selectedSort = type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kOrange : kCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kOrange : Colors.black12,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu pesanan sesuai Figma: info kiri, badge status kanan tengah
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final isDone = status == 'Selesai';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Info kiri
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
                const SizedBox(height: 2),
                Text(
                  order['service'],
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRupiah(order['price']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order['date'],
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Badge status kanan tengah
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

  Widget _buildBottomNav() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: kSage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
      onTap: () => _onBottomNavTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: isActive ? kOrange : Colors.white),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? kOrange : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartitionControlCard(PartitionResult<Map<String, dynamic>> res) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOrange.withValues(alpha: 0.5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Panel Filter (seperti search filter Shopee)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: kOrange),
                  SizedBox(width: 6),
                  Text(
                    'Filter & Batas Harga',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (_selectedMethod != 'Semua' || _customPivot != null || _partitionSide != 'all')
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMethod = 'Semua';
                      _customPivot = null;
                      _partitionSide = 'all';
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: kOrange,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Metode Layanan (Kategori ala Shopee)
          const Text(
            'Metode Layanan:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _methods.map((m) {
                final isSelected = _selectedMethod == m;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMethod = m),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? kOrange : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? kOrange : Colors.black12,
                        ),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Batas Patokan Harga (Pivot)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined, size: 16, color: kOrange),
                  const SizedBox(width: 4),
                  const Text(
                    'Batas Patokan Harga:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatRupiah(res.pivotValue),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showPivotDialog(res.pivotValue),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 13, color: kOrange),
                      SizedBox(width: 2),
                      Text(
                        'Ubah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Konsep QuickSort: data dibagi menjadi Sisi Kiri (≤ Batas) dan Sisi Kanan (> Batas)',
            style: TextStyle(fontSize: 10.5, color: Colors.black54),
          ),
          const SizedBox(height: 8),

          // Tab Pembagian Sisi
          Row(
            children: [
              _buildPartitionFilterTab('Semua (${res.totalCount})', 'all'),
              const SizedBox(width: 6),
              _buildPartitionFilterTab('≤ Kiri (${res.leftCount})', 'left'),
              const SizedBox(width: 6),
              _buildPartitionFilterTab('> Kanan (${res.rightCount})', 'right'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartitionFilterTab(String label, String side) {
    final isSelected = _partitionSide == side;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _partitionSide = side),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? kOrange : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? kOrange : Colors.black12,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartitionSectionHeader({
    required String title,
    required int count,
    required bool isLeft,
  }) {
    return Row(
      children: [
        Icon(
          isLeft ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
          size: 16,
          color: Colors.black87,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isLeft ? kOrange : Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count item',
            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPivotDivider(int pivotValue) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: kOrange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.line_weight_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '🎯 BATAS FILTER: ${_formatRupiah(pivotValue)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showPivotDialog(int currentPivot) {
    final controller = TextEditingController(text: currentPivot.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kCream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.tune_rounded, color: kOrange, size: 22),
              SizedBox(width: 8),
              Text(
                'Atur Batas Filter Harga',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nilai patokan batas harga filter untuk membagi data pesanan menjadi sisi kiri (≤ batas) dan sisi kanan (> batas).',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal Batas Harga (Rp)',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Preset Cepat:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _pivotPresetChip(controller, 'Auto (Median)', null),
                  _pivotPresetChip(controller, '15.000', 15000),
                  _pivotPresetChip(controller, '20.000', 20000),
                  _pivotPresetChip(controller, '25.000', 25000),
                  _pivotPresetChip(controller, '30.000', 30000),
                  _pivotPresetChip(controller, '50.000', 50000),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                final val = text.isEmpty ? null : int.tryParse(text);
                setState(() {
                  _customPivot = val;
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }

  Widget _pivotPresetChip(TextEditingController controller, String label, int? value) {
    return InkWell(
      onTap: () {
        if (value == null) {
          controller.text = '';
        } else {
          controller.text = value.toString();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kOrange.withValues(alpha: 0.5)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ),
    );
  }
}
