import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';
import '../../data/models/food_log_model.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodLogsAsync = ref.watch(foodLogProvider);

    return DefaultTabController(
      length: 4, // Breakfast, Lunch, Dinner, Snack 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
              Tab(text: 'Snack'),
            ],
          ),
        ),
        body: foodLogsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (allLogs) {
            return TabBarView(
              children: [
                _buildMealList(allLogs, 'breakfast'),
                _buildMealList(allLogs, 'lunch'),
                _buildMealList(allLogs, 'dinner'),
                _buildMealList(allLogs, 'snack'),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Tampilkan Modal/Dialog Input Makanan Manual di sini 
            // Nanti kita buat form inputnya.
            _showAddFoodDialog(context, ref); 
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMealList(List<FoodLog> allLogs, String mealType) {
    // Filter list berdasarkan Tab Meal Type
    final mealLogs = allLogs.where((log) => log.mealType == mealType).toList();

    if (mealLogs.isEmpty) {
      return Center(child: Text('No food logged for $mealType'));
    }

    return ListView.builder(
      itemCount: mealLogs.length,
      itemBuilder: (context, index) {
        final log = mealLogs[index];
        return ListTile(
          title: Text(log.foodName),
          subtitle: Text('${log.calories} kcal'),
          trailing: Text('P: ${log.protein}g'), // Opsional stats
        );
      },
    );
  }

  void _showAddFoodDialog(BuildContext context, WidgetRef ref) {
    // Dummy function untuk tes "Add"
    // Nanti kita ganti dengan Form input manual yang proper 
    final newLog = FoodLog(
      id: DateTime.now().toString(),
      foodName: 'Test Apple',
      calories: 95,
      mealType: 'breakfast', // Hardcode dulu untuk tes
      createdAt: DateTime.now(),
    );
    ref.read(foodLogProvider.notifier).addLog(newLog);
  }
}