import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/nutrition/providers/nutrition_provider.dart';
import 'package:intl/intl.dart';

class NutritionDetailScreen extends ConsumerWidget {
  const NutritionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodState = ref.watch(nutritionProvider);
    final selectedDate = ref.read(nutritionProvider.notifier).selectedDate;
    // final theme = Theme.of(context); // Unused

    final logs = foodState.value ?? [];
    final totalCalories = logs.fold(0, (sum, item) => sum + item.calories);
    final totalProtein = logs.fold(0, (sum, item) => sum + item.protein);
    final totalCarbs = logs.fold(0, (sum, item) => sum + item.carbs);
    final totalFat = logs.fold(0, (sum, item) => sum + item.fat);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE, d MMMM').format(selectedDate)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              context,
              'Total Calories',
              '$totalCalories kcal',
              Icons.local_fire_department,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Macronutrients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMacroRow(context, 'Protein', totalProtein, Colors.redAccent),
            _buildMacroRow(
              context,
              'Carbohydrates',
              totalCarbs,
              Colors.blueAccent,
            ),
            _buildMacroRow(context, 'Fat', totalFat, Colors.orangeAccent),

            const SizedBox(height: 32),
            const Text(
              'Meal Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMealBreakdown(context, logs, 'breakfast'),
            _buildMealBreakdown(context, logs, 'lunch'),
            _buildMealBreakdown(context, logs, 'dinner'),
            _buildMealBreakdown(context, logs, 'snack'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$value g',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMealBreakdown(BuildContext context, List logs, String type) {
    final mealLogs = logs.where((l) => l.mealType == type).toList();
    if (mealLogs.isEmpty) return const SizedBox.shrink();

    final cals = mealLogs.fold(0, (sum, item) => sum + (item.calories as int));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            type.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            '$cals kcal',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
