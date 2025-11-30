import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/profile/providers/profile_provider.dart';
import 'package:gainers/features/weight/ui/weight_log_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/features/dashboard/ui/widgets/dashboard_card.dart';
import 'package:gainers/features/activity/ui/activity_details_screen.dart';
import 'package:gainers/features/nutrition/ui/nutrition_screen.dart';
import 'package:gainers/features/sleep/ui/sleep_log_screen.dart';
import 'package:gainers/features/activity/providers/activity_details_provider.dart';
import 'package:gainers/features/nutrition/providers/nutrition_provider.dart';
import 'package:gainers/features/hydration/providers/hydration_provider.dart';
import 'package:gainers/features/hydration/ui/hydration_screen.dart';
import 'package:intl/intl.dart';

import 'package:gainers/features/sleep/providers/sleep_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final profileAsync = ref.watch(getProfileProvider(user?.id ?? ''));
    final healthAsync = ref.watch(healthProvider);
    final nutritionAsync = ref.watch(nutritionProvider);
    final hydrationAsync = ref.watch(hydrationProvider);

    // Watch sleep logs for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sleepAsync = ref.watch(weeklySleepLogsProvider(today));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate Nutrition Data
    final int consumedCalories =
        nutritionAsync.value?.fold<int>(
          0,
          (sum, item) => sum + item.calories,
        ) ??
        0;
    const int targetCalories = 2500; // Hardcoded target for now

    // Calculate Activity Data
    final int steps = healthAsync.value?.todaysSteps ?? 0;
    final double distanceKm = (steps * 0.762) / 1000;
    final int burnedCalories = (steps * 0.04).round();
    final double stepProgress = (steps / 10000).clamp(0.0, 1.0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- Header ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                profileAsync.when(
                  data: (profile) {
                    final name =
                        profile?.displayName ?? profile?.username ?? 'Gainer';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $name!',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Here's your summary",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 60),
                  error: (_, __) => const Text('Welcome'),
                ),
                const SizedBox(height: 32),

                // --- Large Summary Card (Activity) ---
                DashboardCard(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActivityDetailsScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daily Activity',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.directions_walk,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              children: [
                                Center(
                                  child: CircularProgressIndicator(
                                    value: stepProgress,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '${(stepProgress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  NumberFormat('#,###').format(steps),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                const Text(
                                  'Steps Taken',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$burnedCalories kcal',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontFamily: 'Lexend',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${distanceKm.toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontFamily: 'Lexend',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Stats Grid ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    // Calories
                    DashboardCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NutritionScreen(),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0), // Light Orange
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lunch_dining,
                              color: Colors.orange,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Calories',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: NumberFormat(
                                    '#,###',
                                  ).format(consumedCalories),
                                ),
                                TextSpan(
                                  text: ' / $targetCalories',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Hydration
                    DashboardCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HydrationScreen(),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD), // Light Blue
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Hydration',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          hydrationAsync.when(
                            data: (logs) {
                              final total = logs.fold(
                                0,
                                (sum, item) => sum + item.amountMl,
                              );
                              return RichText(
                                text: TextSpan(
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${(total / 1000).toStringAsFixed(1)}L',
                                    ),
                                    TextSpan(
                                      text: ' / 2.0L',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const Text('Loading...'),
                            error: (_, __) => const Text('--'),
                          ),
                        ],
                      ),
                    ),

                    // Sleep
                    DashboardCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SleepLogScreen(),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E5F5), // Light Purple
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bedtime,
                              color: Colors.purple,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Sleep',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          sleepAsync.when(
                            data: (logs) {
                              // Filter for today's logs (start time is today)
                              final now = DateTime.now();
                              final todayLogs = logs.where((log) {
                                return log.startTime.year == now.year &&
                                    log.startTime.month == now.month &&
                                    log.startTime.day == now.day;
                              });

                              final totalMinutes = todayLogs.fold<int>(
                                0,
                                (sum, log) => sum + log.durationMinutes,
                              );
                              final hours = totalMinutes ~/ 60;
                              final minutes = totalMinutes % 60;

                              return Text(
                                '${hours}h ${minutes}m',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              );
                            },
                            loading: () => const Text('Loading...'),
                            error: (_, __) => const Text('--'),
                          ),
                        ],
                      ),
                    ),

                    // Weight
                    DashboardCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeightLogScreen(),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1), // Light Teal
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.monitor_weight,
                              color: Colors.teal,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Weight',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profileAsync.value?.weightKg ?? '--'} kg',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
