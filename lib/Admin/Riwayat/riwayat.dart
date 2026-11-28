import 'dart:async';
import 'package:flutter/material.dart';
import '../Detail/detail_pesanan.dart';
import '../../services/supabase_service.dart';
import '../../utils/partition_helper.dart';

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
  static const Color kCream = Color(0xFFFFF3D0);

  List<Map<String, dynamic>> _orders = [];
  String _selectedSort = 'default'; // 'default', 'price_asc', 'price_desc', 'partition'
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;
  int? _customPivot;
  String _partitionSide = 'all'; // 'all', 'left', 'right'

  final List<String> _methods = [
    'Semua',
    'Cuci Kering',
    'Cuci Setrika',
    'Setrika Saja',
    'Express',
  ];
  String _selectedMethod = 'Semua';

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

  List<Map<String, dynamic>> get _baseOrders {
    return _orders
        .where((o) => _matchesMethod((o['service'] ?? '').toString()))
        .toList();
  }

  PartitionResult<Map<String, dynamic>> get _partitionResult {
    return PartitionHelper.partition<Map<String, dynamic>>(
      items: _baseOrders,
      valueExtractor: (o) => (o['price'] is num)
          ? (o['price'] as num).toInt()
          : int.tryParse(o['price']?.toString() ?? '0') ?? 0,
      customPivot: _customPivot,
    );
  }

  List<Map<String, dynamic>> get _sortedOrders {
    final list = List<Map<String, dynamic>>.from(_baseOrders);
    if (_selectedSort == 'price_asc') {
      list.sort((a, b) {
        final pA = (a['price'] is num)
            ? (a['price'] as num).toInt()
            : int.tryParse(a['price']?.toString() ?? '0') ?? 0;
        final pB = (b['price'] is num)
            ? (b['price'] as num).toInt()
            : int.tryParse(b['price']?.toString() ?? '0') ?? 0;
        return pA.compareTo(pB);
      });
      return list;
    } else if (_selectedSort == 'price_desc') {
      list.sort((a, b) {
        final pA = (a['price'] is num)
            ? (a['price'] as num).toInt()
            : int.tryParse(a['price']?.toString() ?? '0') ?? 0;
        final pB = (b['price'] is num)
            ? (b['price'] as num).toInt()
            : int.tryParse(b['price']?.toString() ?? '0') ?? 0;
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
    final orders = _sortedOrders;

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

              const SizedBox(height: 14),

              // ===== Sort Section =====
              _buildSortBar(),
              const SizedBox(height: 12),

              // ===== Partition Control Card =====
              if (_selectedSort == 'partition' && _baseOrders.isNotEmpty) ...[
                _buildPartitionControlCard(_partitionResult),
                const SizedBox(height: 12),
              ],

              // List riwayat
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kOrange))
                    : orders.isEmpty
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
                        : (_selectedSort == 'partition' && _partitionSide == 'all')
                            ? RefreshIndicator(
                                color: kOrange,
                                onRefresh: () => _loadHistory(),
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.only(bottom: 24),
                                  children: [
                                    // Sisi Kiri
                                    _buildPartitionSectionHeader(
                                      title: 'Sisi Kiri: Harga ≤ ${_rupiah(_partitionResult.pivotValue)}',
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
                                            padding: const EdgeInsets.only(bottom: 14),
                                            child: _buildOrderCard(o),
                                          )),

                                    const SizedBox(height: 6),
                                    // Garis Pembatas Pivot
                                    _buildPivotDivider(_partitionResult.pivotValue),
                                    const SizedBox(height: 12),

                                    // Sisi Kanan
                                    _buildPartitionSectionHeader(
                                      title: 'Sisi Kanan: Harga > ${_rupiah(_partitionResult.pivotValue)}',
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
                                            padding: const EdgeInsets.only(bottom: 14),
                                            child: _buildOrderCard(o),
                                          )),
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
                                  itemCount: orders.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                                  itemBuilder: (context, index) =>
                                      _buildOrderCard(orders[index]),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Row(
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
                  label: _selectedMethod == 'Semua' ? 'Filter' : 'Filter ($_selectedMethod)',
                  type: 'partition',
                  icon: Icons.filter_list_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartitionControlCard(PartitionResult<Map<String, dynamic>> res) {
    return Container(
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
                      _rupiah(res.pivotValue),
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
            '🎯 BATAS FILTER: ${_rupiah(pivotValue)}',
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
                'Nilai patokan batas harga untuk membagi data pesanan menjadi sisi kiri (≤ batas filter) dan sisi kanan (> batas filter).',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal Batas Filter (Rp)',
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
