import 'package:flutter/material.dart';

/// Model untuk layanan laundry
class LaundryServiceItem {
  final String id;
  final String title;
  final int pricePerKg;
  final IconData icon;
  final String description;
  int quantity;
  String note;

  LaundryServiceItem({
    required this.id,
    required this.title,
    required this.pricePerKg,
    required this.icon,
    required this.description,
    this.quantity = 0,
    this.note = '',
  });

  int get subtotal => quantity * pricePerKg;

  String get formattedPrice => 'Rp. ${_formatNumber(pricePerKg)}/kg';
  String get formattedSubtotal => 'Rp ${_formatNumber(subtotal)}';

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

/// State keranjang laundry yang dapat diakses antar halaman
class LaundryCart extends ChangeNotifier {
  static final LaundryCart instance = LaundryCart._internal();

  LaundryCart._internal() {
    _initDefaultItems();
  }

  final Map<String, LaundryServiceItem> _services = {};

  void _initDefaultItems() {
    // Sesuai gambar Figma: Cuci Kering (2 kg) dan Setrika Saja (1 kg) default aktif
    _services['cuci_kering'] = LaundryServiceItem(
      id: 'cuci_kering',
      title: 'Cuci Kering',
      pricePerKg: 8000,
      icon: Icons.checkroom_rounded,
      description: 'Pakaian dicuci dengan mesin dan dikeringkan tanpa disetrika.',
      quantity: 2,
    );

    _services['cuci_setrika'] = LaundryServiceItem(
      id: 'cuci_setrika',
      title: 'Cuci Setrika',
      pricePerKg: 12000,
      icon: Icons.local_laundry_service_rounded,
      description: 'Pakaian dicuci, dikeringkan, dan disetrika rapi wangi.',
      quantity: 0,
    );

    _services['setrika_saja'] = LaundryServiceItem(
      id: 'setrika_saja',
      title: 'Setrika Saja',
      pricePerKg: 7000,
      icon: Icons.iron_rounded,
      description: 'Pakaian datang hanya untuk di setrika tapa dicuci',
      quantity: 1,
    );

    _services['express'] = LaundryServiceItem(
      id: 'express',
      title: 'Express',
      pricePerKg: 15000,
      icon: Icons.thunderstorm_rounded,
      description: 'Layanan kilat selesai dalam 3-6 jam dengan kualitas terbaik.',
      quantity: 0,
    );
  }

  List<LaundryServiceItem> get allServices => _services.values.toList();

  List<LaundryServiceItem> get cartItems =>
      _services.values.where((item) => item.quantity > 0).toList();

  int get totalPrice =>
      cartItems.fold(0, (total, item) => total + item.subtotal);

  String get formattedTotalPrice => 'Rp ${LaundryServiceItem._formatNumber(totalPrice)}';

  void increment(String id) {
    if (_services.containsKey(id)) {
      _services[id]!.quantity++;
      notifyListeners();
    }
  }

  void decrement(String id) {
    if (_services.containsKey(id) && _services[id]!.quantity > 0) {
      _services[id]!.quantity--;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    if (_services.containsKey(id)) {
      _services[id]!.quantity = 0;
      notifyListeners();
    }
  }

  void setNote(String id, String note) {
    if (_services.containsKey(id)) {
      _services[id]!.note = note;
      notifyListeners();
    }
  }

  void clearCart() {
    for (var item in _services.values) {
      item.quantity = 0;
      item.note = '';
    }
    notifyListeners();
  }

  void resetToDemo() {
    _initDefaultItems();
    notifyListeners();
  }
}
