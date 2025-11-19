import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/features/auth/ui/auth_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Handle logout
              await Supabase.instance.client.auth.signOut();

              // Navigate back to AuthScreen after logout
              // Ensure context is still valid before using it.
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome!'),
            if (user != null) ...[
              const SizedBox(height: 8),
              Text('UID: ${user.id}'),
              const SizedBox(height: 8),
              Text('Email: ${user.email}'),
            ]
          ],
        ),
      ),
    );
  }
}
