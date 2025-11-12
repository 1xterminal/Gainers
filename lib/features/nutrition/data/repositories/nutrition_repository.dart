import '../models/food_log_model.dart';

// 1. Abstract Class (Kontrak)
abstract class NutritionRepository {
  Future<void> addFoodLog(FoodLog log);
  Future<List<FoodLog>> getFoodLogs(DateTime date);
}

// 2. Fake Implementation (Untuk Development UI sekarang)
class FakeNutritionRepository implements NutritionRepository {
  final List<FoodLog> _dummyStorage = [];

  @override
  Future<void> addFoodLog(FoodLog log) async {
    // Simulasi delay seolah-olah kirim ke internet
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyStorage.add(log);
  }

  @override
  Future<List<FoodLog>> getFoodLogs(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Filter data dummy (abaikan tanggal dulu untuk tes sederhana)
    return _dummyStorage;
  }
}