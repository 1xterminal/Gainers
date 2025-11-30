import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/dashboard/ui/dashboard_screen.dart';
import 'package:gainers/features/activity/ui/exercise_tutorial_screen.dart';
import 'package:gainers/features/profile/ui/profile_screen.dart';
import 'package:gainers/features/progress/ui/progress_screen.dart';
import 'package:gainers/layout/providers/navigation_provider.dart';
import 'package:gainers/core/services/notification_service.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  @override
  void initState() {
    super.initState();
    // Schedule hydration reminder when the main layout is loaded
    NotificationService().scheduleHydrationReminder();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const DashboardScreen(),
      const ExerciseTutorialScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // This switches the screen based on the index
      body: IndexedStack(index: selectedIndex, children: screens),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
        },
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
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
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
}
