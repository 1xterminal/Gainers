import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/food_log_model.dart';
import '../../data/repositories/nutrition_repository.dart';

// Provider untuk Repository (Saat ini pakai Fake, nanti ganti Supabase di sini saja)
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return FakeNutritionRepository();
});

// Provider untuk List Makanan (State UI)
class FoodLogNotifier extends StateNotifier<AsyncValue<List<FoodLog>>> {
  final NutritionRepository _repository;

  FoodLogNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      state = const AsyncValue.loading();
      final logs = await _repository.getFoodLogs(DateTime.now());
      state = AsyncValue.data(logs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addLog(FoodLog log) async {
    try {
      await _repository.addFoodLog(log);
      // Refresh list setelah tambah data
      loadLogs(); 
    } catch (e) {
      // Handle error (bisa tambah state error handling khusus jika mau)
    }
  }
}

final foodLogProvider = StateNotifierProvider<FoodLogNotifier, AsyncValue<List<FoodLog>>>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return FoodLogNotifier(repository);
});