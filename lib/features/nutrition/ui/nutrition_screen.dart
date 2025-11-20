import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        // Menampilkan data berdasarkan status (Loading / Error / Data Ada)
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
          child: const Icon(Icons.add),
          tooltip: 'Add Food',
        ),
      ),
    );
  }

  // Widget pembantu untuk membuat List Makanan
  Widget _buildList(List<FoodLog> logs, String type) {
    // Filter data sesuai Tab yang aktif
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
            // Menampilkan detail makro (Protein, Carbs, Fat)
            trailing: Text(
              'P:${item.protein} C:${item.carbs} F:${item.fat}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  // Dialog Pop-up Input Manual
  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    String selectedMeal = 'breakfast'; // Default value

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        // Perlu StatefulBuilder agar Dropdown bisa berubah nilai
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
                      labelText: 'Food Name (e.g. Nasi Goreng)',
                    ),
                  ),
                  TextField(
                    controller: calCtrl,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedMeal,
                    decoration: const InputDecoration(labelText: 'Meal Type'),
                    items: ['breakfast', 'lunch', 'dinner', 'snack'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedMeal = val);
                      }
                    },
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

                  final log = FoodLog(
                    userId: 'dummy-user-id', // Nanti ambil dari Auth Provider
                    foodName: nameCtrl.text,
                    calories: int.tryParse(calCtrl.text) ?? 0,
                    mealType: selectedMeal,
                    createdAt: DateTime.now(),
                  );

                  // Panggil Provider untuk simpan data
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
