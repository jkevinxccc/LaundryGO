import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order['status'];
  }

  List<Map<String, dynamic>> get _items =>
      List<Map<String, dynamic>>.from(widget.order['items'] ?? []);

  int get _subtotal => _items.fold(
      0, (sum, item) => sum + (item['qty'] as int) * (item['pricePerKg'] as int));

  String _rupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }

  void _handleSave() {
    // TODO: simpan ke API / database di sini
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status diubah menjadi $_selectedStatus'),
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
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ubah Status pesanan',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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

  /// Satu baris item laundry (ikon + nama + qty x harga + total)
  Widget _buildItemRow(Map<String, dynamic> item) {
    final int qty = item['qty'];
    final int pricePerKg = item['pricePerKg'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(item['icon'] as IconData, color: Colors.blue, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$qty Kg x ${_rupiah(pricePerKg)}',
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                    Text(
                      _rupiah(qty * pricePerKg),
                      style: const TextStyle(fontSize: 10, color: Colors.black),
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