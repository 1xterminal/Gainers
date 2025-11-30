import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/food_model.dart';
import '../data/nutrition_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Provider Repository
final nutritionRepositoryProvider = Provider((ref) {
  return NutritionRepository(Supabase.instance.client);
});

final nutritionDateProvider = NotifierProvider<NutritionDateNotifier, DateTime>(
  NutritionDateNotifier.new,
);

class NutritionDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

// 2. Async Notifier (Pengelola Data List Makanan)
class NutritionNotifier extends AsyncNotifier<List<FoodLog>> {
  @override
  Future<List<FoodLog>> build() async {
    final repo = ref.read(nutritionRepositoryProvider);
    final date = ref.watch(nutritionDateProvider);
    return repo.getFoodLogs(date);
  }

  Future<void> addLog(FoodLog log) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final previousState = state;
    // Optimistic update
    if (state.hasValue) {
      final currentLogs = state.value!;
      state = AsyncValue.data([...currentLogs, log]);
    }

    try {
      await repo.addFoodLog(log);
      // Silent reload to get the real ID and ensure consistency
      final date = ref.read(nutritionDateProvider);
      final freshLogs = await repo.getFoodLogs(date);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLog(int id) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final previousState = state;
    // Optimistic update
    if (state.hasValue) {
      final currentLogs = state.value!;
      state = AsyncValue.data(
        currentLogs.where((log) => log.id != id).toList(),
      );
    }

    try {
      await repo.deleteFoodLog(id);
      // Silent reload
      final date = ref.read(nutritionDateProvider);
      final freshLogs = await repo.getFoodLogs(date);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLog(FoodLog log) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final previousState = state;
    // Optimistic update
    if (state.hasValue) {
      final currentLogs = state.value!;
      final index = currentLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        final updatedLogs = List<FoodLog>.from(currentLogs);
        updatedLogs[index] = log;
        state = AsyncValue.data(updatedLogs);
      }
    }

    try {
      await repo.updateFoodLog(log);
      // Silent reload
      final date = ref.read(nutritionDateProvider);
      final freshLogs = await repo.getFoodLogs(date);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }
}

// 3. Provider Utama yang akan dipanggil di UI
final nutritionProvider =
    AsyncNotifierProvider<NutritionNotifier, List<FoodLog>>(() {
      return NutritionNotifier();
    });
