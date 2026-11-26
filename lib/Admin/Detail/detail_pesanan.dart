import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class DetailPesananPage extends StatefulWidget {
  /// Data pesanan dari halaman list (Map), isinya:
  /// id, name, service, price, date, status, items
  final Map<String, dynamic> order;

  const DetailPesananPage({super.key, required this.order});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  // Palet Warna Sesuai Desain Figma
  static const Color kBackground = Color(0xFFA9C8E0);
  static const Color kOrange = Color(0xFFDE9556);
  static const Color kSage = Color(0xFF9BA87A);
  static const Color kCream = Color(0xFFFFF3D0);

  final List<String> _statuses = ['Pending', 'Diproses', 'Selesai'];
  late String _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final st = widget.order['status']?.toString() ?? 'Pending';
    if (st == 'Baru' || st == 'Pending') {
      _selectedStatus = 'Pending';
    } else if (_statuses.contains(st)) {
      _selectedStatus = st;
    } else {
      _selectedStatus = 'Pending';
    }
  }

  List<Map<String, dynamic>> get _items =>
      List<Map<String, dynamic>>.from(widget.order['items'] ?? []);

  int get _subtotal {
    if (_items.isEmpty) return widget.order['price'] as int? ?? 0;
    return _items.fold(
      0, (sum, item) {
        final sub = item['subTotal'] as int?;
        if (sub != null && sub > 0) return sum + sub;
        final qty = (item['qty'] as int?) ?? 1;
        final price = (item['pricePerKg'] as int?) ?? 0;
        return sum + (qty * price);
      },
    );
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

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final rawId = widget.order['raw_id'] as int? ??
        int.tryParse(widget.order['id'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;

    if (rawId > 0) {
      try {
        await SupabaseService.updateStatusPesanan(rawId, _selectedStatus);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah status: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status pesanan ${widget.order['id']} berhasil diubah menjadi $_selectedStatus'),
        backgroundColor: const Color(0xFF2DBC9E),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(_selectedStatus); // kirim status baru ke list
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header Pesanan (hijau sage) =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kSage,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    if (order['payment_method'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Pembayaran: ${order['payment_method']}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                    if (order['customer_phone'] != null && order['customer_phone'] != '-') ...[
                      const SizedBox(height: 2),
                      Text(
                        'No. Telp: ${order['customer_phone']}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                    if (order['customer_address'] != null && order['customer_address'] != '-') ...[
                      const SizedBox(height: 2),
                      Text(
                        'Alamat: ${order['customer_address']}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Item Laundry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),

              // ===== Kartu Item Laundry (krem, border oranye) =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kOrange, width: 1),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    ..._items.map((item) => _buildItemRow(item)),
                    const Divider(color: Colors.black54, thickness: 1.2, height: 1),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            _rupiah(_subtotal),
                            style: const TextStyle(fontSize: 11, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ===== Kartu Status Pesanan =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: kCream,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Status Pesanan',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: kSage,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2)),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          dropdownColor: kSage,
                          borderRadius: BorderRadius.circular(6),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.black, size: 28),
                          style: const TextStyle(fontSize: 13, color: Colors.black),
                          items: _statuses
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedStatus = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ===== Tombol Ubah Status =====
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    disabledBackgroundColor: kOrange.withAlpha(153),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Ubah Status pesanan',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Satu baris item laundry (ikon + nama + catatan + qty x harga + total)
  Widget _buildItemRow(Map<String, dynamic> item) {
    final int qty = (item['qty'] as int?) ?? 1;
    final int pricePerKg = (item['pricePerKg'] as int?) ?? 0;
    final String catatan = item['catatan']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item['icon'] as IconData? ?? Icons.local_laundry_service_outlined, color: Colors.blue, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? 'Layanan',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (catatan.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Catatan: $catatan',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$qty Kg x ${_rupiah(pricePerKg)}',
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                    Text(
                      _rupiah(qty * pricePerKg),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}