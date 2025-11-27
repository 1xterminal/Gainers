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
      body: foodState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          final filteredLogs = logs
              .where((l) => l.mealType == mealType)
              .toList();
          final totalCalories = filteredLogs.fold(
            0,
            (sum, item) => sum + item.calories,
          );
          final totalProtein = filteredLogs.fold(
            0,
            (sum, item) => sum + item.protein,
          );
          final totalCarbs = filteredLogs.fold(
            0,
            (sum, item) => sum + item.carbs,
          );
          final totalFat = filteredLogs.fold(0, (sum, item) => sum + item.fat);

          return CustomScrollView(
            slivers: [
              // 1. Dynamic Sliver App Bar
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    mealType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _getGradientColors(mealType),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getMealIcon(mealType),
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalCalories kcal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Meal Macros Summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroChip(
                        context,
                        'Protein',
                        '$totalProtein g',
                        Colors.redAccent,
                      ),
                      _buildMacroChip(
                        context,
                        'Carbs',
                        '$totalCarbs g',
                        Colors.blueAccent,
                      ),
                      _buildMacroChip(
                        context,
                        'Fat',
                        '$totalFat g',
                        Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Food List
              filteredLogs.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
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
                              'No food logged yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = filteredLogs[index];
                        return Dismissible(
                          key: Key(item.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            if (item.id != null) {
                              ref
                                  .read(nutritionProvider.notifier)
                                  .deleteLog(item.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.foodName} deleted'),
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerLowest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () => _showAddEditSheet(
                                context,
                                ref,
                                mealType,
                                existingLog: item,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  item.foodName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.foodName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'P:${item.protein}  C:${item.carbs}  F:${item.fat}',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Text(
                                '${item.calories} kcal',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: filteredLogs.length),
                    ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(context, ref, mealType),
        label: const Text('Add Food'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMacroChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return [Colors.orangeAccent, Colors.deepOrange];
      case 'lunch':
        return [Colors.blueAccent, Colors.blue];
      case 'dinner':
        return [Colors.indigoAccent, Colors.indigo];
      case 'snack':
        return [Colors.purpleAccent, Colors.deepPurple];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.local_cafe;
      default:
        return Icons.fastfood;
    }
  }

  void _showAddEditSheet(
    BuildContext context,
    WidgetRef ref,
    String mealType, {
    FoodLog? existingLog,
  }) {
    final nameCtrl = TextEditingController(text: existingLog?.foodName ?? '');
    final calCtrl = TextEditingController(
      text: existingLog?.calories.toString() ?? '',
    );
    final proteinCtrl = TextEditingController(
      text: existingLog?.protein.toString() ?? '',
    );
    final carbsCtrl = TextEditingController(
      text: existingLog?.carbs.toString() ?? '',
    );
    final fatCtrl = TextEditingController(
      text: existingLog?.fat.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existingLog == null
                  ? 'Add to ${mealType.toUpperCase()}'
                  : 'Edit Food',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: calCtrl,
              decoration: const InputDecoration(
                labelText: 'Calories (kcal)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_fire_department),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: proteinCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Protein (g)',
                      border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || calCtrl.text.isEmpty) return;

                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;

                final log = FoodLog(
                  id: existingLog?.id, // Keep ID if editing
                  userId: userId,
                  foodName: nameCtrl.text,
                  calories: int.tryParse(calCtrl.text) ?? 0,
                  protein: int.tryParse(proteinCtrl.text) ?? 0,
                  carbs: int.tryParse(carbsCtrl.text) ?? 0,
                  fat: int.tryParse(fatCtrl.text) ?? 0,
                  mealType: mealType,
                  createdAt:
                      existingLog?.createdAt ??
                      ref.read(nutritionProvider.notifier).selectedDate,
                );

                if (existingLog == null) {
                  ref.read(nutritionProvider.notifier).addLog(log);
                } else {
                  ref.read(nutritionProvider.notifier).updateLog(log);
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(existingLog == null ? 'Add Food' : 'Save Changes'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
