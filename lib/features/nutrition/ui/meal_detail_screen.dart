import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/nutrition/data/food_model.dart';
import 'package:gainers/features/nutrition/providers/nutrition_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealDetailScreen extends ConsumerWidget {
  final String mealType;
  final DateTime date;

  const MealDetailScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodState = ref.watch(nutritionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(mealType.toUpperCase()), centerTitle: true),
      body: foodState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          final filteredLogs = logs
              .where((l) => l.mealType == mealType)
              .toList();

          if (filteredLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_food,
                    size: 64,
                    color: theme.disabledColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No food logged for $mealType',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, ref, mealType),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Food'),
                  ),
                ],
              ),
            );
          }

          final totalCalories = filteredLogs.fold(
            0,
            (sum, item) => sum + item.calories,
          );

          return Column(
            children: [
              // Meal Summary
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerLowest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Calories', style: theme.textTheme.titleMedium),
                    Text(
                      '$totalCalories kcal',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Food List
              Expanded(
                child: ListView.separated(
                  itemCount: filteredLogs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredLogs[index];
                    return Dismissible(
                      key: Key(item.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        if (item.id != null) {
                          ref
                              .read(nutritionProvider.notifier)
                              .deleteLog(item.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.foodName} deleted')),
                          );
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          item.foodName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'P:${item.protein}g  C:${item.carbs}g  F:${item.fat}g',
                        ),
                        trailing: Text(
                          '${item.calories} kcal',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref, mealType),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, String mealType) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to ${mealType.toUpperCase()}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g. Oatmeal',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: calCtrl,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: proteinCtrl,
                      decoration: const InputDecoration(labelText: 'Prot (g)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: carbsCtrl,
                      decoration: const InputDecoration(labelText: 'Carb (g)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || calCtrl.text.isEmpty) return;

              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) return;

              final log = FoodLog(
                userId: userId,
                foodName: nameCtrl.text,
                calories: int.tryParse(calCtrl.text) ?? 0,
                protein: int.tryParse(proteinCtrl.text) ?? 0,
                carbs: int.tryParse(carbsCtrl.text) ?? 0,
                fat: int.tryParse(fatCtrl.text) ?? 0,
                mealType: mealType,
                createdAt: ref.read(nutritionProvider.notifier).selectedDate,
              );

              ref.read(nutritionProvider.notifier).addLog(log);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
