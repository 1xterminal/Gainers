import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/food_model.dart';
import '../../providers/nutrition_provider.dart';
import '../meal_detail_screen.dart';

class MealCard extends ConsumerWidget {
  final String title;
  final List<FoodLog> logs;

  const MealCard({super.key, required this.title, required this.logs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: totalCalories),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutExpo,
                    builder: (context, value, child) {
                      return Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
