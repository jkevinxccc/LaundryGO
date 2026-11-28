import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pengujian Logika Sort Harga (Ascending & Descending)', () {
    final List<Map<String, dynamic>> dummyOrders = [
      {'id': '#LG0001', 'price': 25000, 'name': 'Budi'},
      {'id': '#LG0002', 'price': 10000, 'name': 'Siti'},
      {'id': '#LG0003', 'price': 50000, 'name': 'Andi'},
      {'id': '#LG0004', 'price': 15000, 'name': 'Dewi'},
    ];

    test('Sort Ascending: Harga Terendah ke Tertinggi', () {
      final list = List<Map<String, dynamic>>.from(dummyOrders);
      list.sort((a, b) {
        final pA = (a['price'] as num).toInt();
        final pB = (b['price'] as num).toInt();
        return pA.compareTo(pB);
      });

      expect(list.map((e) => e['price']).toList(), [10000, 15000, 25000, 50000]);
      expect(list.first['id'], '#LG0002');
      expect(list.last['id'], '#LG0003');
    });

    test('Sort Descending: Harga Tertinggi ke Terendah', () {
      final list = List<Map<String, dynamic>>.from(dummyOrders);
      list.sort((a, b) {
        final pA = (a['price'] as num).toInt();
        final pB = (b['price'] as num).toInt();
        return pB.compareTo(pA);
      });

      expect(list.map((e) => e['price']).toList(), [50000, 25000, 15000, 10000]);
      expect(list.first['id'], '#LG0003');
      expect(list.last['id'], '#LG0002');
    });

    test('Sort string price seperti di dashboard user', () {
      final List<Map<String, String>> stringOrders = [
        {'id': '#LG0001', 'harga': '25000'},
        {'id': '#LG0002', 'harga': '10000'},
        {'id': '#LG0003', 'harga': '50000'},
      ];

      // Ascending
      final ascList = List<Map<String, String>>.from(stringOrders);
      ascList.sort((a, b) {
        final pA = int.tryParse(a['harga'] ?? '0') ?? 0;
        final pB = int.tryParse(b['harga'] ?? '0') ?? 0;
        return pA.compareTo(pB);
      });
      expect(ascList.map((e) => e['harga']).toList(), ['10000', '25000', '50000']);

      // Descending
      final descList = List<Map<String, String>>.from(stringOrders);
      descList.sort((a, b) {
        final pA = int.tryParse(a['harga'] ?? '0') ?? 0;
        final pB = int.tryParse(b['harga'] ?? '0') ?? 0;
        return pB.compareTo(pA);
      });
      expect(descList.map((e) => e['harga']).toList(), ['50000', '25000', '10000']);
    });

    test('Total Pendapatan: Menghitung akumulasi seluruh harga pesanan users', () {
      final List<Map<String, dynamic>> pesananSupabase = [
        {'id_pesanan': 1, 'total_harga': 25000, 'status': 'Baru'},
        {'id_pesanan': 2, 'total_harga': 15000, 'status': 'Pending'},
        {'id_pesanan': 3, 'total_harga': 40000, 'status': 'Diproses'},
        {'id_pesanan': 4, 'total_harga': 50000, 'status': 'Selesai'},
        {'id_pesanan': 5, 'total_harga': null, 'status': 'Diproses', 'Detail_Pesanan': [{'sub_total': 10000}]},
      ];

      int totalPendapatan = 0;
      int totalSelesai = 0;

      for (final p in pesananSupabase) {
        final st = p['status']?.toString().toLowerCase().trim() ?? '';
        if (st == 'selesai') {
          totalSelesai++;
        }

        int harga = 0;
        final rawHarga = p['total_harga'];
        if (rawHarga != null) {
          harga = (rawHarga is num)
              ? rawHarga.toInt()
              : (int.tryParse(rawHarga.toString()) ?? 0);
        }

        if (harga == 0 && p['Detail_Pesanan'] != null) {
          final details = p['Detail_Pesanan'] as List<dynamic>? ?? [];
          for (final d in details) {
            final stVal = d['sub_total'];
            if (stVal != null) {
              harga += (stVal is num)
                  ? stVal.toInt()
                  : (int.tryParse(stVal.toString()) ?? 0);
            }
          }
        }

        totalPendapatan += harga;
      }

      // Total seluruh harga: 25000 + 15000 + 40000 + 50000 + 10000 = 140000
      expect(totalPendapatan, 140000);
      expect(totalSelesai, 1);
    });
  });

  group('Pengujian Logika Partition (Sistem SSP: Pembagian QuickSort)', () {
    final List<Map<String, dynamic>> testOrders = [
      {'id': '#LG0001', 'price': 8000},
      {'id': '#LG0002', 'price': 16000},
      {'id': '#LG0003', 'price': 20000},
      {'id': '#LG0004', 'price': 24000},
      {'id': '#LG0005', 'price': 30000},
    ];

    test('Partisi membagi data ke sisi kiri (<= pivot) dan sisi kanan (> pivot)', () {
      const int pivot = 20000;
      final List<Map<String, dynamic>> left = [];
      final List<Map<String, dynamic>> right = [];

      for (final item in testOrders) {
        final price = item['price'] as int;
        if (price <= pivot) {
          left.add(item);
        } else {
          right.add(item);
        }
      }

      // Sisi kiri: 8000, 16000, 20000 (semua <= 20000)
      expect(left.map((e) => e['price']).toList(), [8000, 16000, 20000]);
      for (final item in left) {
        expect(item['price'] as int, lessThanOrEqualTo(pivot));
      }

      // Sisi kanan: 24000, 30000 (semua > 20000)
      expect(right.map((e) => e['price']).toList(), [24000, 30000]);
      for (final item in right) {
        expect(item['price'] as int, greaterThan(pivot));
      }

      // Gabungan partisi [left..., right...] total elemennya tetap sama
      final partitioned = [...left, ...right];
      expect(partitioned.length, testOrders.length);
    });

    test('Partisi otomatis dengan nilai median jika custom pivot tidak ditentukan', () {
      final prices = testOrders.map((e) => e['price'] as int).toList()..sort();
      final medianPivot = prices[prices.length ~/ 2]; // 20000

      expect(medianPivot, 20000);
    });
  });

  group('Pengujian Filter Metode Layanan (Filter: Cuci Kering, Cuci Setrika, Setrika Saja, Express, Semua)', () {
    final List<Map<String, dynamic>> testOrders = [
      {'id': '#LG0001', 'service': 'Cuci Komplit - 3 kg', 'price': 24000},
      {'id': '#LG0002', 'service': 'Cuci Kering - 2 kg', 'price': 16000},
      {'id': '#LG0003', 'service': 'Setrika Saja - 4 kg', 'price': 20000},
      {'id': '#LG0004', 'service': 'Cuci Kilat Express - 2 kg', 'price': 30000},
      {'id': '#LG0005', 'service': 'Cuci Setrika Reguler - 5 kg', 'price': 35000},
    ];

    bool matchesMethod(String service, String selectedMethod) {
      if (selectedMethod == 'Semua') return true;
      final s = service.toLowerCase();
      switch (selectedMethod) {
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
          return s.contains(selectedMethod.toLowerCase());
      }
    }

    test('Filter Semua mengembalikan seluruh pesanan', () {
      final res = testOrders.where((o) => matchesMethod(o['service'], 'Semua')).toList();
      expect(res.length, 5);
    });

    test('Filter Cuci Kering menyaring pesanan cuci kering saja', () {
      final res = testOrders.where((o) => matchesMethod(o['service'], 'Cuci Kering')).toList();
      expect(res.length, 1);
      expect(res.first['id'], '#LG0002');
    });

    test('Filter Cuci Setrika menyaring pesanan komplit dan cuci setrika', () {
      final res = testOrders.where((o) => matchesMethod(o['service'], 'Cuci Setrika')).toList();
      expect(res.length, 2);
      expect(res.map((e) => e['id']).toList(), ['#LG0001', '#LG0005']);
    });

    test('Filter Setrika Saja menyaring pesanan setrika saja tanpa cuci', () {
      final res = testOrders.where((o) => matchesMethod(o['service'], 'Setrika Saja')).toList();
      expect(res.length, 1);
      expect(res.first['id'], '#LG0003');
    });

    test('Filter Express menyaring pesanan express dan kilat', () {
      final res = testOrders.where((o) => matchesMethod(o['service'], 'Express')).toList();
      expect(res.length, 1);
      expect(res.first['id'], '#LG0004');
    });

    test('Kombinasi Filter Metode dan Sort Harga Terendah / Tertinggi', () {
      // Filter Cuci Setrika dan Sort Harga Terendah
      final cuciSetrika = testOrders.where((o) => matchesMethod(o['service'], 'Cuci Setrika')).toList();
      cuciSetrika.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
      expect(cuciSetrika.map((e) => e['price']).toList(), [24000, 35000]);

      // Sort Harga Tertinggi
      cuciSetrika.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
      expect(cuciSetrika.map((e) => e['price']).toList(), [35000, 24000]);
    });
  });
}
