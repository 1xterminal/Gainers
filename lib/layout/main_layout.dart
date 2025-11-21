import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/dashboard/ui/dashboard_screen.dart';
import 'package:gainers/features/profile/ui/profile_screen.dart';
import 'package:gainers/features/nutrition/ui/nutrition_screen.dart';
import 'package:gainers/features/activity/ui/activity_details_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  // The list of your 4 main tabs
  final List<Widget> _pages = [
    const DashboardScreen(),
    const NutritionScreen(), // Replaced Fitness placeholder
    const Center(child: Text("Progress - Coming Soon")),
    const ProfileScreen(),
    const ActivityDetailsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.restaurant_menu), // Changed icon
            selectedIcon: Icon(Icons.restaurant),
            label: 'Nutrition', // Changed label
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.nordic_walking),
            selectedIcon: Icon(Icons.person),
            label: 'Activity',
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
