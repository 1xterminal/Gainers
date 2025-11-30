import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/food_model.dart';
import '../data/nutrition_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Provider Repository
final nutritionRepositoryProvider = Provider((ref) {
  return NutritionRepository(Supabase.instance.client);
});

// 2. Async Notifier (Pengelola Data List Makanan)
class NutritionNotifier extends AsyncNotifier<List<FoodLog>> {
  late final NutritionRepository _repo;
  DateTime _selectedDate = DateTime.now();

  @override
  Future<List<FoodLog>> build() async {
    _repo = ref.watch(nutritionRepositoryProvider);
    return _loadFoodLogs();
  }

  Future<List<FoodLog>> _loadFoodLogs() async {
    return _repo.getFoodLogs(_selectedDate);
  }

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFoodLogs());
  }

  DateTime get selectedDate => _selectedDate;

  Future<void> addLog(FoodLog log) async {
    final previousState = state;
    // Optimistic update
    if (state.hasValue) {
      final currentLogs = state.value!;
      state = AsyncValue.data([...currentLogs, log]);
    }

    try {
      await _repo.addFoodLog(log);
      // Silent reload to get the real ID and ensure consistency
      final freshLogs = await _repo.getFoodLogs(_selectedDate);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLog(int id) async {
    final previousState = state;
    // Optimistic update
    if (state.hasValue) {
      final currentLogs = state.value!;
      state = AsyncValue.data(
        currentLogs.where((log) => log.id != id).toList(),
      );
    }

    try {
      await _repo.deleteFoodLog(id);
      // Silent reload
      final freshLogs = await _repo.getFoodLogs(_selectedDate);
      state = AsyncValue.data(freshLogs);
    } catch (e, st) {
      // Revert on error
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLog(FoodLog log) async {
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
      await _repo.updateFoodLog(log);
      // Silent reload
      final freshLogs = await _repo.getFoodLogs(_selectedDate);
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
