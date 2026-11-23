import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundryapk/main.dart';
import 'package:laundryapk/user/app_logo.dart';

void main() {
  testWidgets('Full flow smoke test: Loading -> Login -> Beranda -> Pesan Layanan -> Keranjang',
      (WidgetTester tester) async {
    // 1. Build app and check Loading screen
    await tester.pumpWidget(const MyApp());
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('LOUNDRYGO'), findsOneWidget);

    // 2. Fast-forward animation & timer to navigate to Login screen
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Login screen elements
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    // 3. Enter credentials and tap Masuk
    await tester.enterText(find.byType(TextField).at(0), 'user@laundrygo.id');
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 4. Verify Beranda elements
    expect(find.text('Halo'), findsOneWidget);
    expect(find.text('Pesan Sekarang'), findsOneWidget);
    expect(find.text('Cuci Kering'), findsOneWidget);
    expect(find.text('Kategori Layanan'), findsOneWidget);

    // 5. Tap "Pesan Sekarang" -> Navigates to Pesan Layanan page
    await tester.tap(find.text('Pesan Sekarang'));
    await tester.pumpAndSettle();

    // Verify Pesan Layanan screen
    expect(find.text('Pesan Layanan'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Keranjang'), findsWidgets);

    // 6. Tap "Keranjang" button -> Navigates to Keranjang screen
    await tester.tap(find.widgetWithText(ElevatedButton, 'Keranjang'));
    await tester.pumpAndSettle();

    // Verify Keranjang screen
    expect(find.text('Catatan item:'), findsWidgets);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
  });
}
