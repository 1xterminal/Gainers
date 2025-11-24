import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gainers/features/auth/ui/auth_gate.dart'; // Import the Gatekeeper
import 'package:gainers/core/theme/app_theme.dart';

void main() async {
  // 1. Start the Engine
  WidgetsFlutterBinding.ensureInitialized();

  // Load env
  await dotenv.load(fileName: ".env");

  // 2. Connect to Supabase (Replace these with your actual keys!)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // 3. Inject State Management (Riverpod) & Run App
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gainers',
      debugShowCheckedModeBanner: false,

      // Use the themes defined in AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system setting
      // 4. Point to the Gatekeeper
      // We DO NOT point to MainLayout or Dashboard directly.
      // We point to AuthGate, which decides where to go.
      home: const AuthGate(),
    );
  }
}
