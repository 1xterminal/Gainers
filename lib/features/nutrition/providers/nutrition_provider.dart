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

  @override
  Future<List<FoodLog>> build() async {
    _repo = ref.watch(nutritionRepositoryProvider);
    return _loadFoodLogs();
  }

  Future<List<FoodLog>> _loadFoodLogs() async {
    // Ambil data (sementara tanggal hari ini diabaikan dulu di repo dummy)
    return _repo.getFoodLogs(DateTime.now());
  }

  Future<void> addLog(FoodLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.addFoodLog(log);
      return _loadFoodLogs();
    });
  }
}

// 3. Provider Utama yang akan dipanggil di UI
final nutritionProvider =
    AsyncNotifierProvider<NutritionNotifier, List<FoodLog>>(() {
      return NutritionNotifier();
    });
