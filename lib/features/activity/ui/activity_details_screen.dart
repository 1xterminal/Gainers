import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gainers/core/widgets/horizontal_date_wheel.dart';
import 'package:gainers/features/activity/providers/activity_details_provider.dart';
import 'package:gainers/features/activity/ui/widgets/activity_radial_chart.dart';
import 'package:gainers/features/activity/ui/widgets/activity_cards.dart';
import 'package:gainers/core/theme/app_theme.dart';

class ActivityDetailsScreen extends ConsumerStatefulWidget {
  const ActivityDetailsScreen({super.key});

  @override
  ConsumerState<ActivityDetailsScreen> createState() =>
      _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends ConsumerState<ActivityDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    //watch health provider to get the data
    final asyncHealthState = ref.watch(healthProvider);

    //get the notifier to update the data
    final notifier = ref.read(healthProvider.notifier);

    //get the bar chart theme from app_theme.dart
    final barTheme = Theme.of(context).extension<BarChartTheme>()!;

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
          top: 20,
          left: 13,
          right: 13,
          bottom: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -- date wheel --
            HorizontalDateWheel(
              selectedDate: notifier.selectedDate,
              onDateSelected: (date) {
                notifier.setDate(date);
              },
            ),

            asyncHealthState.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              //error handling
              error: (e, stack) {
                final errorText = e.toString();
                final isPermissionDenied = errorText.contains(
                  'Permanently Denied!',
                );
                //error screen
                return Center(
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
                );
              },

              data: (healthStats) {
                final stepsShown = healthStats.todaysSteps;
                final distanceShown = stepsShown * 0.0003048;
                final caloriesShown = stepsShown * 0.04;
                final titleString = DateFormat(
                  'MMMM d, yyyy',
                ).format(notifier.selectedDate);

                final double totalDistanceLifetime =
                    healthStats.lifetimeSteps * 0.0003048;

                final double highestDistance =
                    healthStats.highestSteps * 0.0003048;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      titleString,
                      style: barTheme.labelStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // -- syncfusion radial chart --
                    Container(
                      height: 300,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ActivityRadialChart(
                        steps: stepsShown,
                        distance: distanceShown,
                        calories: caloriesShown,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // -- today's stats --
                    ActivityCards.buildSingleInfoCard(
                      context,
                      steps: stepsShown,
                      distance: distanceShown,
                      calories: caloriesShown,
                    ),
                    const SizedBox(height: 24),

                    // -- lifetime stats --
                    ActivityCards.buildLifetimeInfoCard(
                      context,
                      title: 'Cummulative Statistics',
                      steps: healthStats.lifetimeSteps,
                      distance: totalDistanceLifetime,
                      textColor: barTheme.greenBars,
                    ),
                    const SizedBox(height: 24),

                    // -- highest stats --
                    ActivityCards.buildRecordInfoCard(
                      context,
                      title: 'All Time',
                      title2: 'Record',
                      steps: healthStats.highestSteps,
                      distance: highestDistance,
                      textColor: barTheme.toolTipColor,
                      date: healthStats.highestStepsDate,
                    ),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
