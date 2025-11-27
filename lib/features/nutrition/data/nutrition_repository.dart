import 'package:supabase_flutter/supabase_flutter.dart';
import 'food_model.dart';

class NutritionRepository {
  final SupabaseClient _client;

  NutritionRepository(this._client);

  Future<void> addFoodLog(FoodLog log) async {
    // Ensure the log has the correct user ID from the client if not already set (optional safeguard)
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    // Create a map for insertion, ensuring user_id is correct
    final data = log.toJson();
    data['user_id'] = userId;

    await _client.from('food_logs').insert(data);
  }

  Future<List<FoodLog>> getFoodLogs(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    // Filter by date (Start of day to End of day)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: true);

    return (response as List).map((e) => FoodLog.fromJson(e)).toList();
  }

  Future<void> deleteFoodLog(int id) async {
    await _client.from('food_logs').delete().eq('id', id);
  }

  Future<void> updateFoodLog(FoodLog log) async {
    if (log.id == null) throw Exception('Log ID is required for update');
    await _client.from('food_logs').update(log.toJson()).eq('id', log.id!);
  }
}
