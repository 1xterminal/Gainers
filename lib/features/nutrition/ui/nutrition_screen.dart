import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/nutrition_provider.dart';
import '../data/food_model.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodState = ref.watch(nutritionProvider);

    return DefaultTabController(
      length: 4, // Breakfast, Lunch, Dinner, Snack
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition Log'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
              Tab(text: 'Snack'),
            ],
          ),
        ),
        body: foodState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (logs) => TabBarView(
            children: [
              _buildList(logs, 'breakfast'),
              _buildList(logs, 'lunch'),
              _buildList(logs, 'dinner'),
              _buildList(logs, 'snack'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context, ref),
          tooltip: 'Add Food',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildList(List<FoodLog> logs, String type) {
    final filtered = logs.where((l) => l.mealType == type).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_food, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'No food logged for $type',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final item = filtered[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(
              item.foodName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${item.calories} kcal'),
            trailing: Text(
              'P:${item.protein}g  C:${item.carbs}g  F:${item.fat}g',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    String selectedMeal = 'breakfast';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Food Manual'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Food Name',
                      hintText: 'e.g. Nasi Goreng',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: calCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: proteinCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: carbsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Carbs (g)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: fatCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Fat (g)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Meal Type'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMeal,
                        isDense: true,
                        onChanged: (val) {
                          if (val != null) setState(() => selectedMeal = val);
                        },
                        items: ['breakfast', 'lunch', 'dinner', 'snack']
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(val.toUpperCase()),
                              ),
                            )
                            .toList(),
                      ),
                    ),
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
                    mealType: selectedMeal,
                    createdAt: DateTime.now(),
                  );

                  ref.read(nutritionProvider.notifier).addLog(log);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
