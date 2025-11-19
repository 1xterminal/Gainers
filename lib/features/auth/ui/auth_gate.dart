import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/features/auth/ui/auth_screen.dart';
import 'package:gainers/features/dashboard/ui/dashboard_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Adjust recovery timing if needed, though Supabase handles this well.
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. Handle connection states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Check for a valid session
        if (snapshot.hasData && snapshot.data!.session != null) {
          // User is logged in, show the main app content
          return const DashboardScreen();
        } else {
          // User is not logged in, show the authentication screen
          return const AuthScreen();
        }
      },
    );
  }
}
