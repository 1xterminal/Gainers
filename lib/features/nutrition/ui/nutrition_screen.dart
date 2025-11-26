import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../data/food_model.dart';

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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition Log'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(
              220,
            ), // Increased height for summary
            child: Column(
              children: [
                // Date Navigator
                _buildDateNavigator(context, notifier),

                // Summary Card
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
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

                const TabBar(
                  tabs: [
                    Tab(text: 'Breakfast'),
                    Tab(text: 'Lunch'),
                    Tab(text: 'Dinner'),
                    Tab(text: 'Snack'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: foodState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (logs) => TabBarView(
            children: [
              _buildList(logs, 'breakfast', ref),
              _buildList(logs, 'lunch', ref),
              _buildList(logs, 'dinner', ref),
              _buildList(logs, 'snack', ref),
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

  Widget _buildList(List<FoodLog> logs, String type, WidgetRef ref) {
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
              ref.read(nutritionProvider.notifier).deleteLog(item.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.foodName} deleted')),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(
                item.foodName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${item.calories} kcal'),
              trailing: Text(
                'P:${item.protein} C:${item.carbs} F:${item.fat}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
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
                    createdAt: ref
                        .read(nutritionProvider.notifier)
                        .selectedDate, // Use selected date
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
