import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';
import '../data/food_model.dart';
import 'meal_detail_screen.dart';
import 'nutrition_detail_screen.dart';
import '../../../core/widgets/horizontal_date_wheel.dart';
import 'widgets/macro_pie_chart.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodState = ref.watch(nutritionProvider);
    final notifier = ref.read(nutritionProvider.notifier);
    final selectedDate = ref.watch(nutritionProvider.notifier).selectedDate;

    // Calculate totals safely
    final logs = foodState.value ?? [];
    final totalCalories = logs.fold(0, (sum, item) => sum + item.calories);
    final totalProtein = logs.fold(0, (sum, item) => sum + item.protein);
    final totalCarbs = logs.fold(0, (sum, item) => sum + item.carbs);
    final totalFat = logs.fold(0, (sum, item) => sum + item.fat);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Log'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Horizontal Date Wheel (Unique Date Picker)
            HorizontalDateWheel(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                notifier.setDate(date);
              },
            ),

            const SizedBox(height: 16),

            // 2. Macro Pie Chart (Interactive Visualization)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Daily Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      MacroPieChart(
                        protein: totalProtein,
                        carbs: totalCarbs,
                        fat: totalFat,
                        totalCalories: totalCalories,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NutritionDetailScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(
                            'Protein',
                            Colors.redAccent,
                            '$totalProtein g',
                          ),
                          _buildLegendItem(
                            'Carbs',
                            Colors.blueAccent,
                            '$totalCarbs g',
                          ),
                          _buildLegendItem(
                            'Fat',
                            Colors.orangeAccent,
                            '$totalFat g',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Meal Cards (Samsung Health Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMealCard(context, 'Breakfast', logs, ref),
                  _buildMealCard(context, 'Lunch', logs, ref),
                  _buildMealCard(context, 'Dinner', logs, ref),
                  _buildMealCard(context, 'Snack', logs, ref),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      margin: const EdgeInsets.only(bottom: 12),
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
