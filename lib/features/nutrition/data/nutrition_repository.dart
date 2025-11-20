import 'food_model.dart';

class NutritionRepository {
  // Simulasi penyimpanan sementara di memori HP
  final List<FoodLog> _dummyStorage = [];

  Future<void> addFoodLog(FoodLog log) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Pura-pura loading
    _dummyStorage.add(log);
  }

  Future<List<FoodLog>> getFoodLogs(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Nanti logika filter tanggal dari Supabase ditaruh di sini
    return _dummyStorage;
  }
}