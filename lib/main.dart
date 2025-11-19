import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Impor tema dan layar placeholder Anda
import 'core/theme/app_theme.dart';
import 'features/auth/ui/auth_gate.dart';
// import 'features/dashboard/ui/dashboard_screen.dart'; // Akan kita gunakan nanti

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Muat file .env
  await dotenv.load(fileName: ".env");

  // 2. Inisialisasi Supabase
  // Ambil URL dan Key dari .env
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // 3. Jalankan aplikasi dengan Riverpod ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Buat global provider untuk Supabase client (sesuai rencana Riverpod)
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health & Fitness App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Atau ganti ke .light / .dark
      home: const AuthGate(), // Mulai dari AuthScreen
      // Nanti kita akan ganti ini dengan logic auth:
      // home: SplashScreen() yang akan mengecek status auth
    );
  }
}