import 'package:flutter/material.dart';
import 'cart_state.dart';
import '../services/supabase_service.dart';
import 'dashboard.dart';

class PembayaranQrisPage extends StatefulWidget {
  const PembayaranQrisPage({super.key});

  @override
  State<PembayaranQrisPage> createState() => _PembayaranQrisPageState();
}

class _PembayaranQrisPageState extends State<PembayaranQrisPage> {
  final LaundryCart _cart = LaundryCart.instance;

  // Palet Warna Sesuai Desain Figma
  static const Color kBackground = Color(0xFFAFCBE2);
  static const Color kOrange = Color(0xFFDB9558);
  static const Color kSage = Color(0xFF97A87A);
  static const Color kCream = Color(0xFFFDF4D2);

  bool _isProcessing = false;

  void _handleConfirmPayment() async {
    if (_isProcessing) return;

    if (_cart.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada item yang dibayar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    const idMap = {
      'cuci_kering': 1,
      'cuci_setrika': 2,
      'setrika_saja': 3,
      'express': 4,
    };

    final itemsToSave = _cart.cartItems.map((item) {
      return {
        'id_layanan': idMap[item.id] ?? 1,
        'sub_total': item.subtotal,
        'catatan': item.note,
      };
    }).toList();

    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: kOrange),
      ),
    );

    try {
      await SupabaseService.buatPesanan(
        items: itemsToSave,
        metodePembayaran: 'Qris',
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog

      // Clear cart setelah pembayaran berhasil
      _cart.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran QRIS berhasil! Pesanan Anda telah dibuat.'),
          backgroundColor: Color(0xFF2DBC9E),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Alihkan langsung ke halaman pesanan (tab Pesanan di MainPage)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 1),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Pembayaran',
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
              // ===== Kartu Besar Krem (Tempat Menampilkan QRIS) =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: kCream,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/qris.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/qris.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackQrisCard();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== Kartu Sage Bagian Bawah: Total Harga & Konfirmasi =====
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
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _cart.formattedTotalPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tombol Konfirmasi Oranye
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handleConfirmPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          disabledBackgroundColor: kOrange.withValues(alpha: 0.5),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi',
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

  /// Tampilan Fallback jika gambar asset tidak dapat dimuat
  Widget _buildFallbackQrisCard() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'QRIS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'GPN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'QR Code Standar Pembayaran Nasional',
            style: TextStyle(fontSize: 8, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'LAUNDRYGO',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const Text(
            'NMID: ID1020036000014',
            style: TextStyle(fontSize: 9, color: Colors.black45),
          ),
          const SizedBox(height: 12),
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: const Icon(Icons.qr_code_2_rounded, size: 150, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text(
            'Scan QR untuk membayar',
            style: TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
