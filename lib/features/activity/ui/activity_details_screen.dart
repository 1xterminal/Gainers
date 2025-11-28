import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gainers/features/activity/providers/activity_details_provider.dart';
import 'package:gainers/features/activity/ui/widgets/activity_bar_chart.dart';
import 'package:gainers/features/activity/ui/widgets/activity_cards.dart';
import 'package:gainers/core/theme/app_theme.dart';

class ActivityDetailsScreen extends ConsumerStatefulWidget {
  const ActivityDetailsScreen({super.key});

  @override
  ConsumerState<ActivityDetailsScreen> createState() =>
      _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends ConsumerState<ActivityDetailsScreen> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    //watch health provider to get the data
    final asyncHealthState = ref.watch(healthProvider);

    //get the bar chart theme from app_theme.dart
    final barTheme = Theme.of(context).extension<BarChartTheme>()!;

    return asyncHealthState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      //error handling
      error: (e, stack) {
        final errorText = e.toString();
        final isPermissionDenied = errorText.contains('Permanently Denied!');

        return Scaffold(
          appBar: AppBar(title: const Text('Activity Details')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPermissionDenied
                        ? 'Permission Required'
                        : 'Could Not Load Activity Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString().replaceAll('Exception:', ''),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  if (isPermissionDenied)
                    ElevatedButton(
                      onPressed: () => openAppSettings(),
                      child: const Text('Open Settings'),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(healthProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      data: (healthStats) {
        final lastSevenDays = healthStats.weeklyData;
        final stepsToday = healthStats.todaysSteps;

        int stepsShown;
        double distanceShown;
        double caloriesShown;
        String titleString;

        if (_selectedIndex == -1 ||
            _selectedIndex == lastSevenDays.length - 1) {
          stepsShown = stepsToday;
          distanceShown = stepsShown * 0.0003048;
          caloriesShown = stepsShown * 0.04;
          titleString = 'Today';
        } else {
          final selectedData = lastSevenDays[_selectedIndex];
          stepsShown = selectedData.steps;
          distanceShown = stepsShown * 0.0003048;
          caloriesShown = stepsShown * 0.04;
          titleString = DateFormat('MMMM d, yyyy').format(selectedData.date);
        }

        final double totalDistanceLifetime =
            healthStats.lifetimeSteps * 0.0003048;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.refresh(healthProvider),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 40,
              left: 13,
              right: 13,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -- bar chart --
                Text(
                  'Last 7 Days',
                  style: barTheme.labelStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ActivityBarChart(
                    data: lastSevenDays,
                    selectedIndex: _selectedIndex,
                    onBarSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // -- today's stats --
                Text(
                  titleString,
                  style: barTheme.labelStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ActivityCards.buildSingleInfoCard(
                  context,
                  steps: stepsShown,
                  distance: distanceShown,
                  calories: caloriesShown,
                ),
                const SizedBox(height: 40),

                // -- lifetime stats --
                Text(
                  'Lifetime Stats',
                  style: barTheme.labelStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    ActivityCards.buildDoubleInfoCard(
                      title: 'Total Steps',
                      value: NumberFormat(
                        '#,###',
                      ).format(healthStats.lifetimeSteps),
                      icon: Icons.directions_run,
                      iconColor: barTheme.barColor,
                      cardColor: barTheme.gridColor,
                      textColor: barTheme.labelStyle.color!,
                    ),
                    const SizedBox(width: 16),
                    ActivityCards.buildDoubleInfoCard(
                      title: 'Total Distance (km)',
                      value: NumberFormat(
                        '#,###',
                      ).format(totalDistanceLifetime),
                      icon: Icons.arrow_circle_right_outlined,
                      iconColor: barTheme.barColor,
                      cardColor: barTheme.gridColor,
                      textColor: barTheme.labelStyle.color!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
