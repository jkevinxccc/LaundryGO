import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
import 'loading.dart';
import 'login.dart';
import 'User/dashboard.dart';
import 'User/pesan_layanan.dart';
import 'User/keranjang.dart';
import 'User/riwayat_pesanan.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation & status bar matching app design
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase Backend
  await SupabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaundryGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.logoOrange,
          surface: AppColors.background,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const MainPage(),
        '/pesan_layanan': (context) => const PesanLayananPage(),
        '/keranjang': (context) => const KeranjangPage(),
        '/riwayat_pesanan': (context) => const RiwayatPesananPage(),
      },
    );
  }
}
