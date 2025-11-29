import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';
import 'nutrition_detail_screen.dart';
import '../../../core/widgets/horizontal_date_wheel.dart';
import 'widgets/macro_pie_chart.dart';
import 'widgets/meal_card.dart';

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
                  MealCard(title: 'Breakfast', logs: logs),
                  MealCard(title: 'Lunch', logs: logs),
                  MealCard(title: 'Dinner', logs: logs),
                  MealCard(title: 'Snack', logs: logs),
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
}
