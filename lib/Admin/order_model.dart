import 'package:flutter/material.dart';

// ---------- Warna (sesuai desain) ----------
class AppColors {
  static const background = Color(0xFFA9C8E0);
  static const orange = Color(0xFFDE9556);
  static const cream = Color(0xFFFFF3D0);
  static const olive = Color(0xFF9BA87A);
}

// ---------- Model ----------
class OrderItem {
  final String name;
  final int qty; // dalam Kg
  final int pricePerKg;
  final IconData icon;

  const OrderItem({
    required this.name,
    required this.qty,
    required this.pricePerKg,
    this.icon = Icons.checkroom,
  });

  int get total => qty * pricePerKg;
}

class Order {
  final String id;
  final String name;
  final String service;
  final int price;
  final String date;
  final String status; // 'Pending' | 'Diproses' | 'Selesai'
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.name,
    required this.service,
    required this.price,
    required this.date,
    required this.status,
    this.items = const [],
  });

  Order copyWith({String? status}) => Order(
        id: id,
        name: name,
        service: service,
        price: price,
        date: date,
        status: status ?? this.status,
        items: items,
      );
}

// ---------- Helper format rupiah: 24000 -> "Rp 24,000" ----------
String formatRupiah(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return 'Rp $buffer';
}