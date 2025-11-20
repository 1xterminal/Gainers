import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/profile/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/features/dashboard/ui/widgets/dashboard_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final profileAsync = ref.watch(getProfileProvider(user?.id ?? ''));

    // NOTE: No Scaffold here. Just the content.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GREETING SECTION ---
            profileAsync.when(
              data: (profile) {
                // Prefer Display Name, fallback to Username, then generic
                final name =
                    profile?.displayName ?? profile?.username ?? 'Gainer';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => const Text('Welcome back!'),
            ),

            const SizedBox(height: 24),

            // --- ACTIVITY CARD (Steps) ---
            DashboardCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: Center(
                        child: Text("Activity Details - Coming Soon"),
                      ),
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Steps',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.directions_walk, color: Colors.orange),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: 0.65,
                          strokeWidth: 8,
                          backgroundColor: Colors.black12,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '6,500 / 10,000',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('🔥 320 kcal'),
                            Text('📍 4.2 km'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- GRID FOR OTHER STATS ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // Adjusted aspect ratio to prevent bottom overflow
              childAspectRatio: 1.3,
              children: [
                DashboardCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(
                          body: Center(child: Text("Nutrition - Coming Soon")),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.red),
                      Spacer(),
                      Text('Calories', style: TextStyle(color: Colors.grey)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '1,200 / 2,500',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DashboardCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(
                          body: Center(child: Text("Hydration - Coming Soon")),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue),
                      Spacer(),
                      Text('Hydration', style: TextStyle(color: Colors.grey)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '4 / 8 Glasses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DashboardCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(
                          body: Center(
                            child: Text("Activity Details - Coming Soon"),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bedtime, color: Colors.deepPurple),
                      Spacer(),
                      Text('Sleep', style: TextStyle(color: Colors.grey)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '7h 30m',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Add padding at bottom so the Navbar doesn't cover the last cards
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
