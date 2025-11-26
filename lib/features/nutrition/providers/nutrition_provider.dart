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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.addFoodLog(log);
      return _loadFoodLogs();
    });
  }

  Future<void> deleteLog(int id) async {
    // Optimistic update (optional) or just reload
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteFoodLog(id);
      return _loadFoodLogs();
    });
  }
}

// 3. Provider Utama yang akan dipanggil di UI
final nutritionProvider =
    AsyncNotifierProvider<NutritionNotifier, List<FoodLog>>(() {
      return NutritionNotifier();
    });
