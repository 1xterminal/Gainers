import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/dashboard/ui/dashboard_screen.dart';
import 'package:gainers/features/activity/ui/exercise_tutorial_screen.dart';
import 'package:gainers/features/sleep/ui/sleep_log_screen.dart';
import 'package:gainers/features/weight/ui/weight_log_screen.dart';
import 'package:gainers/features/profile/ui/profile_screen.dart';
import 'package:gainers/features/progress/ui/progress_screen.dart';
import 'package:gainers/layout/providers/navigation_provider.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);

    final screens = [
      const DashboardScreen(),
      const ExerciseTutorialScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // Logic: Only show the "Quick Add" FAB on the Home Tab (Index 0)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showQuickAddModal(context),
              child: const Icon(Icons.add),
            )
          : null,

      // This switches the screen based on the index
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.ondemand_video),
            selectedIcon: Icon(Icons.ondemand_video),
            label: 'Fitness',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'My Page',
          ),
        ],
      ),
    );
  }

  void _showQuickAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Log', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickAction(
                    icon: Icons.local_drink,
                    label: 'Water',
                    onTap: () {},
                  ),
                  _QuickAction(
                    icon: Icons.fastfood,
                    label: 'Food',
                    onTap: () {},
                  ),
                  _QuickAction(icon: Icons.bed, label: 'Sleep', onTap: () {}),
                  _QuickAction(
                    icon: Icons.monitor_weight,
                    label: 'Weight',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper widget for the modal
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).primaryColor.withAlpha((255 * 0.1).round()),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
