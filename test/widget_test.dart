import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundryapk/main.dart';
import 'package:laundryapk/User/app_logo.dart';
import 'package:laundryapk/User/dashboard.dart';
import 'package:laundryapk/User/keranjang.dart';

void main() {
  testWidgets('Smoke test: Loading -> Login -> Beranda -> Keranjang',
      (WidgetTester tester) async {
    // 1. Build app and check Loading screen
    await tester.pumpWidget(const MyApp());
    expect(find.byType(AppLogo), findsOneWidget);

    // 2. Fast-forward animation & timer to navigate to Login screen
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Login screen elements
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    // 3. Test MainPage directly
    await tester.pumpWidget(
      const MaterialApp(
        home: MainPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Halo'), findsOneWidget);
    expect(find.text('Pesan Sekarang'), findsOneWidget);
    expect(find.text('Cuci Kering'), findsOneWidget);
    expect(find.text('Kategori Layanan'), findsOneWidget);

    // 4. Test Keranjang screen
    await tester.pumpWidget(
      const MaterialApp(
        home: KeranjangPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total Harga'), findsWidgets);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Payment'), findsWidgets);
  });
}
