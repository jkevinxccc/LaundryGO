import 'package:flutter/material.dart';
import 'cart_state.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final LaundryCart _cart = LaundryCart.instance;

  // Palet Warna Sesuai Desain Figma
  static const Color kBackground = Color(0xFFAFCBE2);
  static const Color kOrange = Color(0xFFDB9558);
  static const Color kSage = Color(0xFF97A87A);
  static const Color kPillBg = Color(0xFFA6BEBB);
  static const Color kCream = Color(0xFFFDF4D2);
  static const Color kDropdownSelected = Color(0xFFFFD983);
  static const Color kDropdownBlue = Color(0xFFA8C7FA);

  String _selectedPayment = 'Cash';
  bool _isPaymentOpen = false;

  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChange);
    for (var item in _cart.allServices) {
      _noteControllers[item.id] = TextEditingController(text: item.note);
    }
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChange);
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCartChange() {
    if (mounted) setState(() {});
  }

  void _handleCheckout() {
    if (_cart.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang kosong, silakan pilih layanan terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Save notes
    for (var item in _cart.cartItems) {
      final ctrl = _noteControllers[item.id];
      if (ctrl != null) {
        _cart.setNote(item.id, ctrl.text);
      }
    }

    // Tampilkan Dialog Checkout Berhasil
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2DBC9E), size: 28),
            SizedBox(width: 10),
            Text(
              'Pesanan Berhasil!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesanan laundry Anda telah diterima dan akan segera diproses.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran:',
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(
                        _cart.formattedTotalPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Metode Pembayaran:',
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(
                        _selectedPayment,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(); // close dialog
                Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/dashboard');
              },
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cart.cartItems;

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
          'Keranjang',
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
              // ===== Kartu Besar Hijau Sage =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Total Harga di dalam kartu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _cart.formattedTotalPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (cartItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Tidak ada item di keranjang.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: cartItems.map((item) {
                          return _buildDetailedCartItem(item);
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== Bagian Bawah: Ringkasan, Dropdown Payment, Tombol Checkout =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    // Baris Total Harga
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _cart.formattedTotalPrice,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Baris Payment Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _buildPaymentDropdown(),
                      ],
                    ),

                    if (_isPaymentOpen) ...[
                      const SizedBox(height: 8),
                      _buildPaymentOptionsList(),
                    ],

                    const SizedBox(height: 16),

                    // Tombol Checkout Oranye
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: cartItems.isEmpty ? null : _handleCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          disabledBackgroundColor: kOrange.withValues(alpha: 0.5),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Detail Item Laundry dengan Counter dan Catatan
  Widget _buildDetailedCartItem(LaundryServiceItem item) {
    if (!_noteControllers.containsKey(item.id)) {
      _noteControllers[item.id] = TextEditingController(text: item.note);
    }
    final noteController = _noteControllers[item.id]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Layanan
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),

          // Deskripsi
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Harga / kg dan Counter [- 2 +]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.formattedPrice,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: kPillBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _cart.decrement(item.id),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          '–',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _cart.increment(item.id),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Label Catatan
          const Text(
            'Catatan item:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          // Input Box Catatan Krem Lembut
          Container(
            decoration: BoxDecoration(
              color: kCream,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: noteController,
              onChanged: (text) => _cart.setNote(item.id, text),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                hintText: 'Tambahkan catatan khusus...',
                hintStyle: TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol Pembuka Dropdown Payment
  Widget _buildPaymentDropdown() {
    return InkWell(
      onTap: () => setState(() => _isPaymentOpen = !_isPaymentOpen),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedPayment.isEmpty ? 'Payment' : _selectedPayment,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _isPaymentOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  /// List Opsi Dropdown Sesuai Gambar (Dro... preview di gambar)
  Widget _buildPaymentOptionsList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          _buildPaymentOptionItem('Cash', isFirst: true),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          _buildPaymentOptionItem('Qris', isLast: true),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionItem(String method, {bool isFirst = false, bool isLast = false}) {
    final isSelected = _selectedPayment == method;
    // Pada gambar, opsi yang dipilih diberi warna latar (kuning soft / biru soft)
    final Color bgColor = isSelected ? (method == 'Qris' ? kDropdownBlue : kDropdownSelected) : Colors.transparent;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPayment = method;
          _isPaymentOpen = false;
        });
      },
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(8) : Radius.zero,
        bottom: isLast ? const Radius.circular(8) : Radius.zero,
      ),
      child: Container(
        width: double.infinity,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              method,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 18, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
