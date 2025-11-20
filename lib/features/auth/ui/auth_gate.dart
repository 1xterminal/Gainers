import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/features/auth/ui/auth_screen.dart';
import 'package:gainers/features/profile/providers/profile_provider.dart';
import 'package:gainers/features/profile/ui/profile_setup_screen.dart';

// NEW IMPORT: Import your layout
import 'package:gainers/layout/main_layout.dart'; 

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  
  // Helper to check local storage
  Future<bool> _checkIfSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_profile_skipped') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data!.session != null) {
          final userId = snapshot.data!.session!.user.id;

          // Check both Database AND Local Storage
          return FutureBuilder<List<bool>>(
            future: Future.wait([
              ref.read(isProfileCompleteProvider(userId).future),
              _checkIfSkipped(),
            ]),
            builder: (context, combinedSnapshot) {
              if (combinedSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final results = combinedSnapshot.data;
              final isCompleteInDb = results?[0] ?? false;
              final isSkippedLocally = results?[1] ?? false;

              if (isCompleteInDb || isSkippedLocally) {
                // SUCCESS: Go to the Main Shell (Navbar + Dashboard)
                return const MainLayout(); 
              } else {
                // INCOMPLETE: Go to Setup (No Navbar)
                return const ProfileSetupScreen();
              }
            },
          );
        } else {
          // LOGGED OUT: Go to Auth (No Navbar)
          return const AuthScreen();
        }
      },
    );
  }
}