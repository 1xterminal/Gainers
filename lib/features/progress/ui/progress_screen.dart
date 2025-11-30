import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/activity/providers/activity_details_provider.dart';
import 'package:gainers/features/activity/ui/widgets/activity_cards.dart';
import 'package:gainers/features/nutrition/providers/nutrition_provider.dart';
import 'package:gainers/features/nutrition/ui/widgets/macro_pie_chart.dart';
import 'package:gainers/features/sleep/data/sleep_model.dart';
import 'package:gainers/features/sleep/providers/sleep_provider.dart';
import 'package:gainers/features/sleep/ui/widgets/sleep_consistency_chart.dart';
import 'package:gainers/features/weight/providers/weight_provider.dart';
import 'package:gainers/features/weight/ui/widgets/weight_history_list.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  final int initialScreenIndex;
  const ProgressScreen({super.key, this.initialScreenIndex = 0});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialScreenIndex;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SvgPicture.asset(
            'images/Logo-Gainers.svg',
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Text(
              'Progress',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Steps', icon: Icon(Icons.directions_walk)),
              Tab(text: 'Calories', icon: Icon(Icons.local_fire_department)),
              Tab(text: 'Sleep', icon: Icon(Icons.bed)),
              Tab(text: 'Weight', icon: Icon(Icons.monitor_weight)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStepsTab(),
                _buildCaloriesTab(),
                _buildSleepTab(),
                _buildWeightTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    final healthAsync = ref.watch(healthProvider);

    return healthAsync.when(
      data: (data) {
        // Estimate distance and calories
        final todayDistance = data.todaysSteps * 0.0008; // approx km
        final todayCalories = data.todaysSteps * 0.04; // approx kcal

        final lifetimeDistance = data.lifetimeSteps * 0.0008;

        final highestDistance = data.highestSteps * 0.0008;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActivityCards.buildSingleInfoCard(
                context,
                steps: data.todaysSteps,
                distance: todayDistance,
                calories: todayCalories,
              ),
              const SizedBox(height: 16),
              ActivityCards.buildLifetimeInfoCard(
                context,
                title: 'Lifetime Steps',
                steps: data.lifetimeSteps,
                distance: lifetimeDistance,
                textColor: Colors.purple,
              ),
              const SizedBox(height: 16),
              ActivityCards.buildRecordInfoCard(
                context,
                title: 'Highest',
                title2: 'Record',
                steps: data.highestSteps,
                distance: highestDistance,
                date: data.highestStepsDate,
                textColor: Colors.amber,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildCaloriesTab() {
    final nutritionAsync = ref.watch(nutritionProvider);

    return nutritionAsync.when(
      data: (logs) {
        final totalCalories = logs.fold(0, (sum, item) => sum + item.calories);
        final totalProtein = logs.fold(0, (sum, item) => sum + item.protein);
        final totalCarbs = logs.fold(0, (sum, item) => sum + item.carbs);
        final totalFat = logs.fold(0, (sum, item) => sum + item.fat);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Today\'s Nutrition',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              MacroPieChart(
                protein: totalProtein,
                carbs: totalCarbs,
                fat: totalFat,
                totalCalories: totalCalories,
                onTap: () {}, // No navigation needed here
              ),
              const SizedBox(height: 24),
              // Simple summary list
              _buildMacroRow('Protein', totalProtein, Colors.redAccent),
              _buildMacroRow('Carbs', totalCarbs, Colors.blueAccent),
              _buildMacroRow('Fat', totalFat, Colors.orangeAccent),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildMacroRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            '$value g',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTab() {
    final now = DateTime.now();
    // Normalize to midnight to ensure stable provider key
    final date = DateTime(now.year, now.month, now.day);
    final weeklySleepAsync = ref.watch(weeklySleepLogsProvider(date));

    return weeklySleepAsync.when(
      data: (logs) {
        final todayLog = logs.firstWhere(
          (log) => DateUtils.isSameDay(log.startTime, date),
          orElse: () => SleepLog(
            id: '',
            userId: '',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            durationMinutes: 0,
            createdAt: DateTime.now(),
          ),
        );

        final todayDurationMinutes = todayLog.durationMinutes;
        final todayHours = todayDurationMinutes / 60.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ActivityCards.buildDoubleInfoCard(
                    title: 'Last Night\'s Sleep',
                    value: '${todayHours.toStringAsFixed(1)} h',
                    icon: Icons.bed,
                    iconColor: Colors.indigo,
                    cardColor: Theme.of(context).cardColor,
                    textColor:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Sleep Trend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: SleepConsistencyChart(
                  weeklyLogs: logs,
                  selectedDate: date,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildWeightTab() {
    final recentWeightAsync = ref.watch(recentWeightLogsProvider);

    return recentWeightAsync.when(
      data: (logs) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Recent Weight Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (logs.isEmpty)
                const Text('No weight logs yet.')
              else
                WeightHistoryList(logs: logs),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
