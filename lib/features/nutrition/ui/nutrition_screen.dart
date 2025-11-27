import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../data/food_model.dart';
import 'meal_detail_screen.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodState = ref.watch(nutritionProvider);
    final notifier = ref.read(nutritionProvider.notifier);

    // Calculate totals safely
    final logs = foodState.value ?? [];
    final totalCalories = logs.fold(0, (sum, item) => sum + item.calories);
    final totalProtein = logs.fold(0, (sum, item) => sum + item.protein);
    final totalCarbs = logs.fold(0, (sum, item) => sum + item.carbs);
    final totalFat = logs.fold(0, (sum, item) => sum + item.fat);

    // Target (Hardcoded for now, ideally from profile)
    const targetCalories = 2000;
    final progress = (totalCalories / targetCalories).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Log')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date Navigator
            _buildDateNavigator(context, notifier),

            // Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calories',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '$totalCalories / $targetCalories kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: progress > 1.0 ? Colors.red : Colors.green,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  // Macro Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroItem(
                        context,
                        'Protein',
                        totalProtein,
                        Colors.redAccent,
                      ),
                      _buildMacroItem(
                        context,
                        'Carbs',
                        totalCarbs,
                        Colors.blueAccent,
                      ),
                      _buildMacroItem(
                        context,
                        'Fat',
                        totalFat,
                        Colors.orangeAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Meal Cards List
            _buildMealCard(context, 'Breakfast', logs, ref),
            _buildMealCard(context, 'Lunch', logs, ref),
            _buildMealCard(context, 'Dinner', logs, ref),
            _buildMealCard(context, 'Snack', logs, ref),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigator(BuildContext context, NutritionNotifier notifier) {
    final date = notifier.selectedDate;
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                notifier.setDate(date.subtract(const Duration(days: 1))),
          ),
          Text(
            isToday ? 'Today' : DateFormat('EEE, d MMM').format(date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday
                ? null
                : () => notifier.setDate(date.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$value g',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    String title,
    List<FoodLog> logs,
    WidgetRef ref,
  ) {
    final mealType = title.toLowerCase();
    final mealLogs = logs.where((l) => l.mealType == mealType).toList();
    final totalCalories = mealLogs.fold(0, (sum, item) => sum + item.calories);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealDetailScreen(
                mealType: mealType,
                date: ref.read(nutritionProvider.notifier).selectedDate,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMealIcon(mealType),
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mealLogs.isEmpty
                          ? 'No food logged'
                          : '${mealLogs.length} items',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Calories & Add Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalCalories',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.nights_stay_outlined;
      case 'snack':
        return Icons.local_cafe_outlined;
      default:
        return Icons.fastfood;
    }
  }
}
